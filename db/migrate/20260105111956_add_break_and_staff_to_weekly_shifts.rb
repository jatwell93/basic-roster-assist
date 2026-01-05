class AddBreakAndStaffToWeeklyShifts < ActiveRecord::Migration[8.1]
  def change
    add_column :weekly_shifts, :break_start_time, :time, null: true
    add_column :weekly_shifts, :break_end_time, :time, null: true
    add_reference :weekly_shifts, :assigned_staff, foreign_key: { to_table: :users }, null: true
  end
end
