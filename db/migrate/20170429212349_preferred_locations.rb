class PreferredLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :preferred_locations, id: false do |t|
      t.belongs_to :instructor, index: true
      t.belongs_to :location, index: true
    end
    remove_column :instructors, :preferred_locations, :string
  end
end
