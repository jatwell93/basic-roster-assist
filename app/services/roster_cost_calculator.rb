class RosterCostCalculator
  def initialize(roster:)
    raise ArgumentError, "Roster is required" unless roster

    @roster = roster
    @user = roster.user
  end

  def calculate_total_cost
    shifts = @roster.respond_to?(:weekly_shifts) ? @roster.weekly_shifts : @roster.base_shifts
    shifts.sum do |shift|
      calculate_shift_cost(shift)
    end
  end

  private

  def calculate_shift_cost(shift)
    return 0.0 unless @user && @user.hourly_rate

    # Calculate duration in hours: (end_time - start_time) / 3600
    duration_hours = (shift.end_time - shift.start_time) / 3600.0

    # Calculate cost: duration_hours * hourly_rate
    duration_hours * @user.hourly_rate
  end
end
