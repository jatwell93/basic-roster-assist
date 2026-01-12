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
    created_count = 0
    errors = []
    
    shifts_params.each do |index, shift_attrs|
      shift = @roster.base_shifts.build(
        day_of_week: shift_attrs[:day_of_week],
        start_time: shift_attrs[:start_time],
        end_time: shift_attrs[:end_time],
        work_section_id: shift_attrs[:work_section_id].presence
      )
      
      if shift.save
        created_count += 1
      else
        errors << "Shift #{index.to_i + 1}: #{shift.errors.full_messages.join(', ')}"
      end
    end
    
    if errors.empty?
      redirect_to roster_path(@roster), notice: "Successfully created #{created_count} shifts."
    else
      redirect_to roster_path(@roster), alert: "Created #{created_count} shifts. Errors: #{errors.join('; ')}"
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
