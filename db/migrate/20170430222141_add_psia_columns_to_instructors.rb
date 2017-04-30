class AddPsiaColumnsToInstructors < ActiveRecord::Migration[5.0]
  def change
  	add_column :instructors, :contact_email, :string
  	add_column :instructors, :performance_ranking, :integer
  	remove_column :instructors, :adults_initial_rank, :integer
  	remove_column :instructors, :kids_initial_rank, :integer
  	remove_column :instructors, :how_did_you_hear, :string
  	remove_column :instructors, :kids_eligibility, :boolean
  	remove_column :instructors, :seniors_eligibility, :boolean
  	remove_column :instructors, :adults_eligibility, :boolean
  	remove_column :instructors, :preferred_locations, :string
  	add_column :instructors, :home_resort_location, :integer
  end
end
