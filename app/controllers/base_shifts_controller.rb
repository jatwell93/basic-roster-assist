class BaseShiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_roster, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_base_shift, only: [ :edit, :update, :destroy ]
  before_action :authorize_roster_owner!

  def new
    @base_shift = @roster.base_shifts.build
  end

  def create
    @base_shift = @roster.base_shifts.build(base_shift_params)

    if @base_shift.save
      redirect_to roster_path(@roster), notice: "Shift created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @base_shift and @roster already set by before_action
  end

  def update
    if @base_shift.update(base_shift_params)
      redirect_to roster_path(@roster), notice: "Shift updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @base_shift.destroy
    redirect_to roster_path(@roster), notice: "Shift deleted successfully."
  end

  private

  def set_roster
    @roster = BaseRoster.find(params[:roster_id])
  end

  def set_base_shift
    @base_shift = @roster.base_shifts.find(params[:id])
  end

  def authorize_roster_owner!
    redirect_to rosters_path, alert: "Not authorized" unless @roster.user == current_user
  end

  def base_shift_params
    params.require(:base_shift).permit(:day_of_week, :shift_type, :start_time, :end_time)
  end
end
