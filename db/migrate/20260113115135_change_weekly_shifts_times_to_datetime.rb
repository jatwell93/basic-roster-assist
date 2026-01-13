class ChangeWeeklyShiftsTimesToDatetime < ActiveRecord::Migration[8.1]
  def up
    # Change start_time, end_time, break_start_time, break_end_time from time to datetime
    # to properly support overnight shifts that span across midnight
    # PostgreSQL needs explicit conversion: combine current date with time
    change_column :weekly_shifts, :start_time, :datetime, using: "(CURRENT_DATE + start_time)::timestamp"
    change_column :weekly_shifts, :end_time, :datetime, using: "(CURRENT_DATE + end_time)::timestamp"
    change_column :weekly_shifts, :break_start_time, :datetime, using: "(CURRENT_DATE + break_start_time)::timestamp"
    change_column :weekly_shifts, :break_end_time, :datetime, using: "(CURRENT_DATE + break_end_time)::timestamp"
  end
  
  def down
    # Revert back to time columns (cast datetime to time)
    change_column :weekly_shifts, :start_time, :time, using: "start_time::time"
    change_column :weekly_shifts, :end_time, :time, using: "end_time::time"
    change_column :weekly_shifts, :break_start_time, :time, using: "break_start_time::time"
    change_column :weekly_shifts, :break_end_time, :time, using: "break_end_time::time"
  end
end
