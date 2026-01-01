class RosterBudgetCalculator
  def initialize(base_roster)
    raise ArgumentError, "BaseRoster is required" unless base_roster

    @roster = base_roster
    @user = base_roster.user
  end

  def calculate_baseline_sales
    return 0 unless @user&.yearly_sales

    (user.yearly_sales / 52.0).round(2)
  end

  def calculate_baseline_wages
    return 0 unless @user&.wage_percentage_goal && calculate_baseline_sales > 0

    (calculate_baseline_sales * (@user.wage_percentage_goal / 100.0)).round(2)
  end

  def calculate_actual_wages
    @roster.base_shifts.sum do |shift|
      duration_hours = (shift.end_time - shift.start_time) / 3600.0
      duration_hours * (@user&.hourly_rate || 0)
    end.round(2)
  end

  def calculate_wages_percentage(sales = nil, wages = nil)
    sales ||= get_sales_amount
    wages ||= calculate_actual_wages

    return nil if sales.nil? || sales.zero?
    return nil if wages.zero?

    (wages / sales * 100).round(2)
  end

  def sales_and_wages_display
    sales = get_sales_amount
    wages = calculate_actual_wages
    percentage = calculate_wages_percentage(sales, wages)

    # Determine if this is baseline or customized
    is_customized = @roster.is_sales_customized? || @roster.is_wages_customized?

    {
      status: is_customized ? :customized : :baseline,
      sales: sales || 0,
      wages: wages,
      percentage: percentage,
      is_customized:
    }
  end

  def display_percentage_text
    percentage = calculate_wages_percentage
    percentage ? "#{percentage}%" : "--%"
  end

  private

  attr_reader :user

  def get_sales_amount
    if @roster.weekly_sales_forecast.present?
      @roster.weekly_sales_forecast
    elsif @user&.yearly_sales && @user&.wage_percentage_goal
      calculate_baseline_sales
    else
      nil
    end
  end
end
