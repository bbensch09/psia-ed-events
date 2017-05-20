class Instructor < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :locations, dependent: :destroy
  has_and_belongs_to_many :primary_locations, dependent: :destroy
  has_and_belongs_to_many :ski_levels, dependent: :destroy
  has_and_belongs_to_many :snowboard_levels, dependent: :destroy
  has_many :lesson_actions
  has_many :lessons
  has_and_belongs_to_many :sports, dependent: :destroy
  has_many :reviews
  has_many :calendar_blocks
  has_many :sections
  after_create :send_admin_notification
  validates  :first_name, :last_name, presence: true
  has_attached_file :avatar, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
        instructor = Instructor.find_or_create_by(id: row['id'])
        instructor.first_name = row["first_name"]
        instructor.last_name = row["last_name"]
        instructor.contact_email = row["contact_email"]
        instructor.update_attributes(sport_ids: row["sport_ids"].split(",").map{|i| i.to_i })
        instructor.update_attributes(primary_location_ids: row["primary_location_ids"].split(",").map{|i| i.to_i })
        instructor.update_attributes(location_ids: row["location_ids"].split(",").map{|i| i.to_i })
        instructor.update_attributes(ski_level_ids: row["ski_level_ids"].to_i)
        instructor.update_attributes(snowboard_level_ids: row["snowboard_level_ids"].to_i)
        instructor.status = row["status"]
        instructor.performance_ranking = row["performance_ranking"]
        instructor.save!
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{ id  first_name  last_name contact_email phone_number  sport_ids primary_location_ids  location_ids  ski_level snowboard_level status  performance_ranking
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |instructor|
        csv << instructor.attributes.values_at(*desired_columns)
      end
    end
  end

  def self.assign_locations_and_levels
    Instructor.all.each do |instructor|
      instructor.sport_ids = (1..5).to_a.sample
      instructor.location_ids = [14, 26, 21]
      instructor.primary_location_ids = [14,26,21,22,24,8,7,19,27,23,18,20,25,1,5,28,11].sample
      instructor.ski_level_ids = (1..7).to_a.sample
      instructor.snowboard_level_ids = (1..7).to_a.sample
      instructor.performance_ranking = (50..99).to_a.sample
      instructor.city = ['Tahoe City','Truckee','Reno','Mammoth','Los Angeles','Truckee','Kings Beach','Tahoe City','Homewood','South Lake Tahoe','Meyers','Incline Village','Kirkwood'].sample
      instructor.save
    end
  end



  def self.scheduled_for_date(date)
    eligible_shifts = Shift.all.to_a.keep_if {|shift| shift.start_time.to_date == date}
    eligible_shifts = eligible_shifts.keep_if { |shift| shift.status == "Scheduled" || shift.status == "Assigned"}
    instructors = []
    eligible_shifts.each do |shift|
      instructors << Instructor.find(shift.instructor_id)
    end
    return instructors
  end

  def self.create_default_bios
    Instructor.all.each do |instructor|
      if instructor.bio.nil?
      instructor.bio = "TBD - PSIA Level 1 certified instructor."
      instructor.save
      end
    end
  end

  def self.seed_temp_instructors
    first_names = ['Bryan','Heidi','Mitch','Jerry']
    last_names =  ['Schilling','Ettliger','Dion','Smith']
    (0..3).to_a.each do |number|
      Instructor.create!({
        first_name: first_names[number],
        last_name: last_names[number],
        username: "test_user",
        certification: ['Level 1', 'Level 2', 'Level 3', 'HTA'].sample,
        phone_number: "408-315-2900",
        bio: Faker::Hipster.paragraph,
        intro: Faker::StarWars.quote,
        status: "Active",
        adults_initial_rank: (1..10).to_a.sample,
        kids_initial_rank: (1..10).to_a.sample,
        overall_initial_rank: (1..10).to_a.sample,
        city: "Tahoe City",
        confirmed_certification: "True",
        kids_eligibility: true,
        seniors_eligibility: true,
        adults_eligibility: true,        
        age: (18..50).to_a.sample,
        dob: nil,
        ski_level_ids: [[1,2,3,4],[1,2,3,4,5,6,7],[1,2,3,4,5,6,7,8,9]].sample,
        snowboard_level_ids: [[1,2,3,4],[1,2,3,4,5,6,7],[1,2,3,4,5,6,7,8,9]].sample,
        location_ids: 8
        })
    end
    Instructor.all.each do |instructor|
        instructor.sport_ids =  [[1,3],[1],[3]].sample
        instructor.save!        
    end
  end

  def ski_instructor?
    return true if self.sports.include?(Sport.where(name:"Skiing").first)
  end

  def snowboard_instructor?
    return true if self.sports.include?(Sport.where(name:"Snowboarding").first)
  end

  def telemark_instructor?
    return true if self.sports.include?(Sport.where(name:"Telemarking").first)
  end

  def nordic_instructor?
    return true if self.sports.include?(Sport.where(name:"Nordic").first)
  end

  def adaptive_instructor?
    return true if self.sports.include?(Sport.where(name:"Adaptive").first)
  end

  def list_sports
    sports = []
    self.sports.each do |sport|
      sports << sport.name
    end
    sports.join(", ")
  end

  def average_rating
    return 4 if reviews.count == 0
    total_stars = 0
    if self.reviews.count > 0
    self.reviews.each do |review|
      total_stars += review.rating
    end
    end
    return (total_stars.to_f / self.reviews.count.to_f)
  end

  def completed_lessons
    self.lessons.where(state:'Completed')
  end

  def kids_score
    kids_lessons = self.completed_lessons.to_a.keep_if {|lesson| lesson.kids_lesson? }
    points_for_completed_lessons = kids_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.kids_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def seniors_score
    seniors_lessons = self.completed_lessons.to_a.keep_if {|lesson| lesson.seniors_lesson? }
    points_for_completed_lessons = seniors_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.adults_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def overall_score
    points_for_completed_lessons = self.completed_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.overall_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def name
    self.first_name + " " + self.last_name
  end

  def to_param
        [id, name.parameterize].join("-")
  end

  def send_admin_notification
      @instructor = Instructor.last
      LessonMailer.new_instructor_application_received(@instructor).deliver
      puts "an admin notification has been sent."
  end

  def referral_source
      return 'Unknown'
  end


end
