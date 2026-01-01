class RostersController < ApplicationController
  before_action :authenticate_user!

  def index
    @rosters = current_user.base_rosters.includes(:base_shifts).order(created_at: :desc)
  end

  def new
    @roster = current_user.base_rosters.new
  end

  def show
    @roster = current_user.base_rosters.includes(:base_shifts).find(params[:id])
    @shifts_by_day = @roster.base_shifts.group_by(&:day_of_week)

    # Calculate budget and sales vs wages data
    @budget_calculator = RosterBudgetCalculator.new(@roster)
    @budget_display = @budget_calculator.sales_and_wages_display
  end

  def calendar
    # Get current week (Monday to Sunday)
    today = Date.current
    start_of_week = today.beginning_of_week(:monday)
    end_of_week = start_of_week + 6.days

    # Load weekly rosters for current user within this week
    @weekly_rosters = current_user.weekly_rosters
                                  .where(start_date: start_of_week..end_of_week)
                                  .includes(weekly_shifts: [])
                                  .order(:start_date)

    # Calculate sales vs wages percentage for the week
    @sales_vs_wages_percentage = calculate_sales_vs_wages_percentage(start_of_week, end_of_week)

    # If no weekly rosters exist for this week, we could generate them
    # but for now just show what's available
    @week_start = start_of_week
    @week_end = end_of_week
  end

  private

  def calculate_sales_vs_wages_percentage(start_date, end_date)
    # Get total sales for the week
    total_sales = current_user.sales_forecasts
                              .where(start_date: start_date..end_date)
                              .sum(:projected_sales)

    # Get total wages for the week using the roster cost calculator
    total_wages = 0
    @weekly_rosters.each do |roster|
      total_wages += RosterCostCalculator.new(roster).calculate_total_cost
    end

    # Calculate percentage: (sales / wages) * 100, or nil if no wages
    return nil if total_wages.zero?
    return nil if total_sales.zero?

    ((total_sales / total_wages) * 100).round(1)
  end
end
