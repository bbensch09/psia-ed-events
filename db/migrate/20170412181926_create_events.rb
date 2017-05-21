class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.date :date
      t.string :name
      t.string :status
      t.integer :instructor_id

      t.timestamps
    end
  end
end
