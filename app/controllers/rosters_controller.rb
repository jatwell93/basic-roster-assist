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

    # If no weekly rosters exist for this week, we could generate them
    # but for now just show what's available
    @week_start = start_of_week
    @week_end = end_of_week
  end
end
