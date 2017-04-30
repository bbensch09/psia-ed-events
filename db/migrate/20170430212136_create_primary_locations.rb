class CreatePrimaryLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :primary_locations do |t|
		t.string :name
		t.string :partner_status
		t.string :calendar_status
		t.string :region
		t.string :state
		t.string  :logo_file_name
		t.string  :logo_content_type
		t.integer :logo_file_size
		t.datetime :logo_updated_at
		t.integer :vertical_feet
		t.integer :base_elevation
		t.integer :peak_elevation
		t.integer :skiable_acres
		t.integer :average_snowfall
		t.integer :lift_count
		t.string  :address
		t.boolean :night_skiing
		t.string  :city
		t.string  :state_abbreviation
		t.date    :closing_date

      t.timestamps
    end
  end
end
