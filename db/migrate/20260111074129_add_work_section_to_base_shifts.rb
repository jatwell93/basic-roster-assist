class AddWorkSectionToBaseShifts < ActiveRecord::Migration[8.1]
  def change
    add_reference :base_shifts, :work_section, null: true, foreign_key: true
  end
end
