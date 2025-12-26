class CreateWeeklyRostersAndWeeklyShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_rosters do |t|
      t.string :name, null: false
      t.date :week_start_date, null: false
      t.date :week_end_date, null: false
      t.integer :week_type, null: false, default: 0
      t.bigint :base_roster_id, null: false
      t.bigint :user_id, null: false
      t.timestamps
    end

    add_index :weekly_rosters, :base_roster_id
    add_index :weekly_rosters, :user_id

    create_table :weekly_shifts do |t|
      t.bigint :weekly_roster_id, null: false
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :shift_type, null: false
      t.timestamps
    end

    add_index :weekly_shifts, :weekly_roster_id
  end
end
