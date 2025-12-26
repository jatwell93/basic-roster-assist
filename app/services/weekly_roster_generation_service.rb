# frozen_string_literal: true

class WeeklyRosterGenerationService
  attr_reader :base_roster, :week_start_date

  def initialize(base_roster:, week_start_date:)
    @base_roster = base_roster
    @week_start_date = week_start_date
    validate_parameters!
  end

  def generate
    validate_parameters!

    # Check if weekly roster already exists for this week
    if WeeklyRoster.exists?(base_roster: base_roster, week_start_date: week_start_date)
      raise StandardError, "Weekly roster already exists for this week"
    end

    weekly_roster = WeeklyRoster.create!(
      name: base_roster.name,
      week_start_date: week_start_date,
      week_end_date: week_start_date + 6.days,
      base_roster: base_roster,
      user: base_roster.user,
      week_type: base_roster.week_type
    )

    generate_weekly_shifts!(weekly_roster, base_roster.base_shifts)
    weekly_roster
  end

  def week_range
    [ week_start_date, week_start_date + 6.days ]
  end

  private

  def validate_parameters!
    raise ArgumentError, "Base roster is required" unless base_roster
    raise ArgumentError, "Week start date is required" unless week_start_date

    unless base_roster.persisted?
      raise ArgumentError, "BaseRoster must be persisted"
    end

    unless base_roster.base_shifts.any?
      raise StandardError, "Base roster must have shifts to generate weekly roster"
    end
  end

  def generate_weekly_shifts!(weekly_roster, base_shifts)
    base_shifts.each do |base_shift|
      # Calculate the actual date for this shift in the week
      shift_date = calculate_shift_date(weekly_roster.week_start_date, base_shift.day_of_week)

      # Combine the date with the time from base_shift
      start_datetime = combine_date_and_time(shift_date, base_shift.start_time)
      end_datetime = combine_date_and_time(shift_date, base_shift.end_time)

      WeeklyShift.create!(
        weekly_roster: weekly_roster,
        day_of_week: base_shift.day_of_week,
        start_time: start_datetime,
        end_time: end_datetime,
        shift_type: base_shift.shift_type
      )
    end
  end

  private

  def calculate_shift_date(week_start_date, day_of_week)
    # Convert day_of_week to integer if it's a string (from test data)
    day_of_week_int = if day_of_week.is_a?(String)
                        BaseShift.day_of_weeks[day_of_week] || day_of_week.to_i
    else
                        day_of_week
    end

    # day_of_week is 0-6 (Sunday=0, Monday=1, etc.)
    # week_start_date is the start of the week (typically Monday)
    days_to_add = (day_of_week_int - week_start_date.wday) % 7
    week_start_date + days_to_add.days
  end

  def combine_date_and_time(date, time)
    # time is a Time object, we need to change its date to match the shift date
    # while preserving the time components
    # Use the configured time zone to avoid timezone issues
    combined = Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    combined
  end
end
