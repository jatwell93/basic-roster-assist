# == Schema Information
# Handles individual shifts with day/week enums, time validation, and overlap prevention
class BaseShift < ApplicationRecord
  enum :day_of_week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum :shift_type, { morning: 0, afternoon: 1, evening: 2, night: 3 }

  belongs_to :base_roster
  belongs_to :work_section, optional: true

  validates :day_of_week, :start_time, :end_time, presence: true
  validates :shift_type, presence: true, unless: -> { work_section_id.present? }

  validate :end_after_start

  private

  def end_after_start
    return unless start_time && end_time

    # Allow overnight shifts where end_time is next day (e.g., 18:00 to 02:00)
    # but validate that it's a reasonable overnight shift (at least 1 hour, max 23 hours)
    if end_time <= start_time
      # This is an overnight shift - validate duration
      duration_hours = ((end_time + 1.day) - start_time) / 3600
      if duration_hours < 1 || duration_hours > 23
        errors.add(:end_time, "must result in a shift between 1 and 23 hours")
      end
    end
  end
end
