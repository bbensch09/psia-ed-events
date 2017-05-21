require 'csv'

class Event < ApplicationRecord
	  belongs_to :instructor
	  has_many :sections
    belongs_to :sport
    belongs_to :location

  def available_instructors
    all_instructors = self.location.instructors
    eligible_instructors = all_instructors.to_a.keep_if {|instructor| instructor.sports.include?(self.sport)}
    # filter instructors based on qualifications
    eligible_instructors = eligible_instructors.to_a.keep_if {|instructor| instructor.ski_levels.max.value >= self.staff_level.to_i }

    #filter instructors that are already busy on that day
    conflicting_sections = Section.where(date: self.date)
    busy_instructors = []
    conflicting_sections.each do |section|
      busy_instructors << section.instructor
    end
    eligible_instructors = eligible_instructors - busy_instructors

    #rank instructors for whom the location is their home resort first
    ranked_instructors = eligible_instructors.to_a.sort! {|a,b| b.performance_ranking <=> a.performance_ranking }
    ranked_instructors.first(5)
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
