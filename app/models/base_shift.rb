# == Schema Information
# Handles individual shifts with day/week enums, time validation, and overlap prevention
class BaseShift < ApplicationRecord
  enum :day_of_week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum :shift_type, { morning: 0, afternoon: 1, evening: 2, night: 3 }

  belongs_to :base_roster

  validates :day_of_week, :shift_type, :start_time, :end_time, presence: true

  validate :end_after_start
  validate :no_overlapping_shifts

  private

  def end_after_start
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_shifts
    return unless base_roster && day_of_week && start_time && end_time

    overlapping_shifts = BaseShift.where(base_roster: base_roster, day_of_week: day_of_week)
                                  .where.not(id: id)
                                  .where("start_time < ? AND end_time > ?", end_time, start_time)

    if overlapping_shifts.exists?
      errors.add(:base, "Overlaps with existing shift")
    end
  end
end
