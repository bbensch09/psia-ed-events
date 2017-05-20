class Sport < ApplicationRecord
  has_and_belongs_to_many :instructors, dependent: :destroy
  belongs_to :event

  def activity_name
  	case self.name 
  		when "Ski Instructor"
			return "Ski"
		when "Snowboard Instructor"
			return "Snowboard"
	end	
  end
  
end
