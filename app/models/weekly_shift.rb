class WeeklyShift < ApplicationRecord
  belongs_to :weekly_roster
  belongs_to :assigned_staff, class_name: "User", optional: true

  enum :day_of_week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum :shift_type, { morning: 0, afternoon: 1, evening: 2, night: 3 }

  validates :start_time, :end_time, presence: true
  validate :times_in_15_minute_intervals
  validate :no_overlapping_shifts_for_staff
  validate :break_times_valid

  scope :by_day, ->(day) { where(day_of_week: day) }
  scope :for_staff, ->(staff_id) { where(assigned_staff_id: staff_id) }

  # Calculate total paid hours (duration minus break time)
  def paid_hours
    duration = (end_time - start_time) / 3600.0  # Convert seconds to hours
    break_duration = 0

    if break_start_time && break_end_time
      break_duration = (break_end_time - break_start_time) / 3600.0
    end

    [ duration - break_duration, 0 ].max  # Ensure non-negative
  end

  # Total wage cost for this shift
  def wage_cost
    return 0 unless assigned_staff
    paid_hours * (assigned_staff.hourly_rate || 0)
  end

  private

  def times_in_15_minute_intervals
    return unless start_time || end_time

    [ start_time, end_time ].each do |time|
      next unless time
      minutes = time.min
      if (minutes % 15) != 0
        errors.add(:base, "Times must be in 15-minute intervals (got #{minutes} minutes)")
      end
    end
  end

  def no_overlapping_shifts_for_staff
    return unless assigned_staff_id && weekly_roster && start_time && end_time

    overlapping = WeeklyShift.where(
      weekly_roster_id: weekly_roster.id,
      assigned_staff_id: assigned_staff_id,
      day_of_week: day_of_week
    ).where.not(id: id)
     .where("start_time < ? AND end_time > ?", end_time, start_time)

    if overlapping.exists?
      errors.add(:base, "#{assigned_staff.name} already has a shift at this time")
    end
  end

  def break_times_valid
    return unless break_start_time || break_end_time

    if break_start_time && !break_end_time
      errors.add(:break_end_time, "must be set if break start time is provided")
    end

    if break_end_time && !break_start_time
      errors.add(:break_start_time, "must be set if break end time is provided")
    end

    if break_start_time && break_end_time && break_end_time <= break_start_time
      errors.add(:break_end_time, "must be after break start time")
    end

    if break_start_time && start_time && break_start_time < start_time
      errors.add(:break_start_time, "must be after shift start time")
    end

    if break_end_time && end_time && break_end_time > end_time
      errors.add(:break_end_time, "must be before shift end time")
    end
  end
end
