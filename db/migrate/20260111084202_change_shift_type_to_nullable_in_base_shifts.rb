class ChangeShiftTypeToNullableInBaseShifts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :base_shifts, :shift_type, true
  end
end
