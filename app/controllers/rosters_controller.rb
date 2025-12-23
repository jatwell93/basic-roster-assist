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
end
