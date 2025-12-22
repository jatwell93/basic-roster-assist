class ClockInService
  # Custom error classes for specific business logic violations
  class InvalidPinError < StandardError; end
  class AlreadyClockedInError < StandardError; end
  class NotClockedInError < StandardError; end
  class ShiftTooLongError < StandardError; end

  # Maximum allowed shift duration in hours
  MAX_SHIFT_HOURS = 10

  def initialize(user:, pin:)
    validate_parameters!(user, pin)
    @user = user
    @pin = pin
  end

  def clock_in
    validate_pin!
    validate_not_already_clocked_in!

    TimeEntry.create!(
      user: @user,
      clock_in: Time.current,
      clock_out: nil
    )
  end

  def clock_out
    validate_pin!
    ongoing_entry = find_ongoing_entry!
    validate_shift_duration!(ongoing_entry)

    ongoing_entry.update!(clock_out: Time.current)
    ongoing_entry
  end

  private

  def validate_parameters!(user, pin)
    raise ArgumentError, "User is required" if user.nil?
    raise ArgumentError, "PIN is required" if pin.nil?
  end

  def validate_pin!
    unless @user.valid_pin?(@pin)
      raise InvalidPinError, "Invalid PIN provided"
    end
  end

  def validate_not_already_clocked_in!
    if @user.time_entries.where(clock_out: nil).exists?
      raise AlreadyClockedInError, "User is already clocked in"
    end
  end

  def find_ongoing_entry!
    ongoing_entry = @user.time_entries.find_by(clock_out: nil)
    raise NotClockedInError, "User is not currently clocked in" if ongoing_entry.nil?
    ongoing_entry
  end

  def validate_shift_duration!(entry)
    return unless entry.clock_in # Safety check

    hours_worked = entry.hours_worked
    if hours_worked > MAX_SHIFT_HOURS
      raise ShiftTooLongError, "Shift exceeds maximum duration of 10 hours"
    end
  end
end
