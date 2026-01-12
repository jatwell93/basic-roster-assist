class RosterBudgetCalculator
  def initialize(base_roster)
    raise ArgumentError, "BaseRoster is required" unless base_roster

    @roster = base_roster
    @user = base_roster.user
    @hourly_rate = @roster.estimated_hourly_rate || @user.hourly_rate || 25.0
  end

  def calculate
    sales = get_sales_amount
    target_wage_percentage = @roster.wage_percentage
    total_budget = (sales * (target_wage_percentage / 100.0)).round(2)
    
    daily_data = calculate_daily_data
    total_wages = daily_data.sum { |d| d[:cost] }
    
    {
      sales_forecast: sales,
      target_percentage: target_wage_percentage,
      total_budget: total_budget,
      total_actual: total_wages,
      total_variance: total_budget - total_wages,
      average_hourly_rate: @hourly_rate,
      daily_breakdown: daily_data,
      section_breakdown: calculate_section_breakdown,
      is_customized: @roster.weekly_sales_forecast.present?
    }
  end

  def sales_and_wages_display
    # Keep backward compatibility for existing views until fully migrated
    data = calculate
    {
      status: data[:is_customized] ? :customized : :baseline,
      sales: data[:sales_forecast],
      wages: data[:total_actual],
      percentage: data[:sales_forecast] > 0 ? ((data[:total_actual] / data[:sales_forecast]) * 100).round(2) : 0,
      is_customized: data[:is_customized]
    }
  end

  private

  def get_sales_amount
    if @roster.weekly_sales_forecast && @roster.weekly_sales_forecast > 0
      @roster.weekly_sales_forecast
    elsif @user&.yearly_sales
      (@user.yearly_sales / 52.0).round(2)
    else
      0
    end
  end

  def calculate_daily_data
    shifts_by_day = @roster.base_shifts.group_by(&:day_of_week)
    
    # We use 0-6 for Sunday-Saturday (Rails convention), but want to display Monday-Sunday
    # So we'll map Monday(1)..Saturday(6) then Sunday(0)
    ordered_days = %w[monday tuesday wednesday thursday friday saturday sunday]
    
    ordered_days.map do |day_name|
      shifts = shifts_by_day[day_name] || []
      
      hours = shifts.sum do |shift| 
        duration = shift.end_time - shift.start_time
        # Handle overnight shifts
        duration += 24.hours if duration < 0
        duration / 3600.0
      end
      
      cost = (hours * @hourly_rate).round(2)
      
      # Determine daily budget (either manual or 1/7th of total)
      allocations = @roster.daily_budget_allocations || {}
      target = allocations[day_name].to_f
      
      if target.zero?
         # If no manual override, just share budget equally for now, or 0 if sales=0
         total_sales = get_sales_amount
         target = (total_sales * ((@user&.wage_percentage_goal || 14) / 100.0) / 7.0).round(2)
      end

      {
        day: day_name,
        shifts_count: shifts.count,
        hours: hours.round(1),
        cost: cost,
        budget: target,
        variance: target - cost
      }
    end
  end

  def calculate_section_breakdown
    @roster.base_shifts.group_by { |s| s.work_section&.name || s.shift_type.titleize }.map do |section_name, shifts|
      hours = shifts.sum do |shift| 
        duration = shift.end_time - shift.start_time
        duration += 24.hours if duration < 0
        duration / 3600.0
      end
      
      cost = (hours * @hourly_rate).round(2)
      
      {
        name: section_name,
        hours: hours.round(1),
        cost: cost
      }
    end
  end
end
