class CreatePrimarylocationInstructorsJoinTable < ActiveRecord::Migration[5.0]
  def change
  	    create_join_table :instructors, :primary_locations do |t|
  	    end
  end
end

