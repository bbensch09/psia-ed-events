require 'csv'

class Event < ApplicationRecord
	  belongs_to :instructor
	  has_many :sections
    belongs_to :sport
    belongs_to :location

  def available_instructors
    if !self.available_instructor_ids.nil?
    ids = self.available_instructor_ids.split(",")
    instructors = []
    ids.each do |id|
      instructors << Instructor.find(id.to_i)      
    end
    instructors
    else
      instructors = []
    end
  end

  def update_status
    staff_unassigned = 0
    staff_assigned = 0
    staff_confirmed = 0
    self.sections.each do |section|
      case section.instructor_status
      when "Unassigned"
        staff_unassigned +=1
      when "Assigned"
        staff_assigned +=1
      when "Confirmed"
        staff_assigned +=1
        staff_confirmed +=1
      end
    end
    if staff_confirmed == self.capacity / 10
      self.status = "Staff Confirmed"
    elsif staff_assigned == self.capacity / 10
      self.status = "Staff Assigned"
    else
      self.status = "New Event"
    end
    self.save!
  end

  def self.evaluate_all_events
    Event.all.each do |event|
      event.evaluate_available_instructors
      event.update_status
    end
  end

  def print_instructor_names(array)
    puts "::::::::: at this stage, below instructors are eligible::::::::::"
    array.each do |instructor|
      puts instructor.name
    end
  end

  def evaluate_available_instructors
    all_instructors = self.location.instructors
    eligible_instructors = all_instructors.to_a.keep_if {|instructor| instructor.sports.include?(self.sport)}
    # filter instructors based on qualifications
    print_instructor_names(eligible_instructors)
    case self.sport.id
      when 1
      eligible_instructors = eligible_instructors.to_a.keep_if {|instructor| instructor.ski_instructor? && instructor.ski_levels.max.value >= self.staff_level.to_i }
      when 2
      eligible_instructors = eligible_instructors.to_a.keep_if {|instructor| instructor.snowboard_instructor? && instructor.snowboard_levels.max.value >= self.staff_level.to_i }
      else    
    end
    #filter instructors that are already busy on that day
    conflicting_sections = Section.where(date: self.date)
    busy_instructors = []
    conflicting_sections.each do |section|
      busy_instructors << section.instructor
    end
    eligible_instructors = eligible_instructors - busy_instructors

    #rank instructors for whom the location is their home resort first
    ranked_instructors = eligible_instructors.to_a.sort! {|a,b| b.performance_ranking <=> a.performance_ranking }
    primary_instructors = self.primary_location_instructors
    primary_instructors.each do | inst |
      ranked_instructors.unshift(inst)
    end
    ids_to_store = []
    ranked_instructors.first(5).each do |inst|
      ids_to_store << inst.id
    end
    self.available_instructor_ids = ids_to_store.uniq.join(',')
    self.save
  end

  def primary_location_instructors
    primary_location = PrimaryLocation.find(self.location.id)
    all_instructors = primary_location.instructors
    eligible_instructors = all_instructors.to_a.keep_if {|instructor| instructor.sports.include?(self.sport)}
    # filter instructors based on qualifications
    case self.sport.id
      when 1
      eligible_instructors = eligible_instructors.to_a.keep_if {|instructor| instructor.ski_instructor? && instructor.ski_levels.max.value >= self.staff_level.to_i }
      when 2
      eligible_instructors = eligible_instructors.to_a.keep_if {|instructor| instructor.snowboard_instructor? && instructor.snowboard_levels.max.value >= self.staff_level.to_i }
      else    
    end
    #filter instructors that are already busy on that day
    conflicting_sections = Section.where(date: self.date)
    busy_instructors = []
    conflicting_sections.each do |section|
      busy_instructors << section.instructor
    end
    eligible_instructors = eligible_instructors - busy_instructors
  end

  def self.assign_all_remaining_events
    events = Event.joins(:sections).where(sections: {instructor_id:nil})
    events.each do |event|
      event.sections.each do |section|
        if section.event.available_instructors.count > 0
        section.instructor_id = section.event.available_instructors.first.id
        section.instructor_status = 'Assigned'
        section.save!
        event.evaluate_available_instructors
        else
        section.instructor_status = 'Unassigned'
        end
        section.save!
      end
      event.update_status
    end
  end
  
  def self.unassign_all_events
    Event.all.each do |event|
      event.sections.each do |section|
        section.instructor_id = nil
        section.instructor_status = "Unassigned"
        section.save!
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
        event = Event.find_or_create_by(id: row['id'])
        event.update_attributes(row.to_hash)
        event.create_sections_based_on_capacity      
    end
  end

  def create_sections_based_on_capacity
    puts id = self.id
    event = Event.find(self.id)
    sections_needed = (event.capacity / 10.to_f).ceil
    sections_needed.times do 
      Section.create!({
            sport_id: event.sport_id,
            instructor_id: nil,
            date: event.date,
            capacity: 10,
            event_id: event.id,
            instructor_status: "unassigned"
        })
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{ id name category start_time end_time status length_in_days sport_id location_id capacity
    }

    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |event|
        csv << event.attributes.values_at(*desired_columns)
      end
    end
  end


  def self.create_instructor_events(date)
  	Instructor.all.to_a.each do |instructor|
  		Event.create!({
  			start_time: "#{date.to_s} 08:00:00",
  			end_time: "#{date.to_s} 16:00:00",
  			name: ['Snow Rangers - Ski', 'Snow Rangers - Snowboard','Mountain Rangers - Ski', 'Mountain Rangers - Snowboard','Adult Groups - Ski','Adult Groups - Snowboard','Private - Ski','Private - Snowboard'].sample,
  			status: ['TBD','Scheduled','Scheduled','Scheduled','Unavailable'].sample,
  			instructor_id: instructor.id
  			})
  	end
  end

  def self.parametized_date(date)
    return [date.strftime('%m'),date.strftime('%d'),date.year].join('%2F') 
    # "#{date.strftime("%m")}%2F#{date.strftime("%d")}%2F#{date.strftime("%Y")}"
    # "04%2F13%2F2017"
  end

  def self.capacity_status_color(date)
  	case 
  		when self.capacity(date) > 75
  			return "red-shift"
  		when self.capacity(date) > 50
  			return "yellow-shift"
  		else
  			return "green-shift"
	end

  end

  def self.capacity(date)
    total_students = Lesson.bookings_for_date(date)
  	scheduled_instructors = Event.all.to_a.keep_if { |event| event.start_time && event.start_time.to_date == date && event.status == "Scheduled"}
  	# return scheduled_instructors.count
  	avg_capcity_per_instructor = 6
  	return total_capacity = avg_capcity_per_instructor * scheduled_instructors.count
  	# capacity_utilization = (total_students.to_f / total_capacity.to_f) *100
  end

  def event_status_color
  	case self.status
  	when 'TBD'
  		return 'yellow-shift'
  	when 'Scheduled'
  		return 'blue-shift'
  	when 'Unavailable'
  		return 'red-shift'
  	when 'Completed'
  		return 'green-shift'
	when 'Assigned'
		return 'green-shift'
  	end
  end

end
