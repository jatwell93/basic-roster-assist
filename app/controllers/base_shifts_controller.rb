class BaseShiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_roster, only: [ :new, :create, :edit, :update, :destroy, :new_multi, :create_multi ]
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

  def new_multi
    # Render the multi-shift creation form
  end

  def create_multi
    shifts_params = params[:shifts]
    all_shifts = []
    error_shifts = {}

    # Build all shifts first without saving
    shifts_params.each do |index, shift_attrs|
      shift = @roster.base_shifts.build(
        day_of_week: shift_attrs[:day_of_week],
        start_time: shift_attrs[:start_time],
        end_time: shift_attrs[:end_time],
        work_section_id: shift_attrs[:work_section_id].presence
      )

      # Validate but don't save yet
      if !shift.valid?
        error_shifts[index] = shift.errors.full_messages
      end

      all_shifts << shift
    end

    # If any shifts are invalid, render form with errors
    if error_shifts.any?
      @shifts_data = shifts_params
      @error_shifts = error_shifts
      render :new_multi, status: :unprocessable_entity
    else
      # All valid - save all shifts
      saved_count = 0
      all_shifts.each do |shift|
        saved_count += 1 if shift.save
      end

      redirect_to roster_path(@roster), notice: "Successfully created #{saved_count} shifts."
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
    params.require(:base_shift).permit(:day_of_week, :shift_type, :start_time, :end_time, :work_section_id)
  end
end
