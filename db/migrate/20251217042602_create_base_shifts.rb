class CreateBaseShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :base_shifts do |t|
      t.references :base_roster, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.integer :shift_type, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.timestamps
    end
  end
end
