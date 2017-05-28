class AddAvailableInstructorIDsToEvents < ActiveRecord::Migration[5.0]
  def change
  	    add_column :events, :available_instructor_ids, :string
  end
end
