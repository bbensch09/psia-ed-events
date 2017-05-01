class UpdateColumnsForEventsAndSections < ActiveRecord::Migration[5.0]
  def change
  	remove_column :events, :instructor_id, :integer
  	add_column :events, :category, :string
  	add_column :events, :length_in_days, :integer  
  	add_column :events, :sport_id, :integer  
  	add_column :events, :location_id, :integer  
  	add_column :events, :capacity, :integer  
  	add_column :sections, :event_id, :integer  
  	add_column :sections, :instructor_status, :string  
  	remove_column :sections, :status, :string
  	remove_column :sections, :shift_id, :integer
  	remove_column :sections, :age_group, :string
  	remove_column :sections, :lesson_type, :string
  	remove_column :sections, :level, :string
  end
end
