class RostersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_weekly_roster, only: [ :finalize, :available_staff, :check_conflicts ]
  before_action :authorize_roster_owner!, only: [ :finalize, :available_staff, :check_conflicts ]

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

  # API: Get available staff for this user
  def available_staff
    # For now, return all staff users except the current user
    # TODO: Implement proper team management
    staff = User.where(role: :staff).where.not(id: current_user.id).map { |user| { id: user.id, name: user.name, email: user.email } }
    render json: staff
  end

  # API: Create new shift
  def create_shift
    @weekly_roster = current_user.weekly_rosters.find(params[:roster_id])
    return render json: { error: "Unauthorized" }, status: :unauthorized unless @weekly_roster.user == current_user

    @shift = @weekly_roster.weekly_shifts.build(shift_params)

    # Check for conflicts
    conflicting = check_shift_conflicts(@shift)
    return render json: { error: conflicting[:message] }, status: :unprocessable_entity if conflicting[:exists]

    if @shift.save
      render json: { status: "success", shift: shift_json(@shift) }
    else
      render json: { error: @shift.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # API: Update shift (including staff reassignment)
  def update_shift
    @shift = WeeklyShift.find(params[:shift_id])
    @weekly_roster = @shift.weekly_roster
    return render json: { error: "Unauthorized" }, status: :unauthorized unless @weekly_roster.user == current_user

    old_shift_data = shift_json(@shift)
    @shift.assign_attributes(shift_params)

    # Check for conflicts (excluding current shift)
    conflicting = check_shift_conflicts(@shift)
    return render json: { error: conflicting[:message] }, status: :unprocessable_entity if conflicting[:exists]

    if @shift.save
      @weekly_roster.notify_shift_change(@shift, old_shift_data) if @weekly_roster.finalized?
      render json: { status: "success", shift: shift_json(@shift) }
    else
      render json: { error: @shift.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # API: Delete shift
  def destroy_shift
    @shift = WeeklyShift.find(params[:shift_id])
    @weekly_roster = @shift.weekly_roster
    return render json: { error: "Unauthorized" }, status: :unauthorized unless @weekly_roster.user == current_user

    if @shift.destroy
      render json: { status: "success" }
    else
      render json: { error: "Failed to delete shift" }, status: :unprocessable_entity
    end
  end

  # API: Check for shift conflicts
  def check_conflicts
    start_time = params[:start_time]
    end_time = params[:end_time]
    staff_id = params[:staff_id]
    day_of_week = params[:day_of_week]

    conflicting_shifts = WeeklyShift.where(
      weekly_roster: @weekly_roster,
      assigned_staff_id: staff_id,
      day_of_week: day_of_week
    ).where("start_time < ? AND end_time > ?", end_time, start_time)

    if params[:shift_id]
      conflicting_shifts = conflicting_shifts.where.not(id: params[:shift_id])
    end

    if conflicting_shifts.exists?
      conflicts = conflicting_shifts.map do |shift|
        {
          shift_id: shift.id,
          staff_name: shift.assigned_staff&.name,
          start_time: shift.start_time.strftime("%H:%M"),
          end_time: shift.end_time.strftime("%H:%M")
        }
      end
      render json: { conflicts: conflicts }
    else
      render json: { conflicts: [] }
    end
  end

  # API: Finalize roster
  def finalize
    if @weekly_roster.finalize!(current_user)
      render json: {
        status: "success",
        message: "Roster finalized successfully. Emails sent to #{@weekly_roster.weekly_shifts.select(:assigned_staff_id).distinct.count} team members."
      }
    else
      render json: { error: "Failed to finalize roster" }, status: :unprocessable_entity
    end
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

  def set_weekly_roster
    @weekly_roster = current_user.weekly_rosters.find(params[:id])
  end

  def authorize_roster_owner!
    return if @weekly_roster.user == current_user
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def shift_params
    params.require(:shift).permit(
      :day_of_week,
      :start_time,
      :end_time,
      :break_start_time,
      :break_end_time,
      :assigned_staff_id,
      :shift_type
    )
  end

  def check_shift_conflicts(shift)
    return { exists: false } unless shift.assigned_staff_id && shift.start_time && shift.end_time

    conflicting = WeeklyShift.where(
      weekly_roster: shift.weekly_roster,
      assigned_staff_id: shift.assigned_staff_id,
      day_of_week: shift.day_of_week
    ).where("start_time < ? AND end_time > ?", shift.end_time, shift.start_time)
      .where.not(id: shift.id)

    if conflicting.exists?
      { exists: true, message: "#{shift.assigned_staff.name} already has a shift at this time" }
    else
      { exists: false }
    end
  end

  def shift_json(shift)
    {
      id: shift.id,
      day_of_week: shift.day_of_week,
      start_time: shift.start_time.strftime("%H:%M"),
      end_time: shift.end_time.strftime("%H:%M"),
      break_start_time: shift.break_start_time&.strftime("%H:%M"),
      break_end_time: shift.break_end_time&.strftime("%H:%M"),
      assigned_staff_id: shift.assigned_staff_id,
      assigned_staff_name: shift.assigned_staff&.name
    }
  end
end
