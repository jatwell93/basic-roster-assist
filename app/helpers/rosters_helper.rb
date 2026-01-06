module RostersHelper
  def budget_status_color(is_customized)
    is_customized ? "bg-green-50 border-green-200" : "bg-blue-50 border-blue-200"
  end

  def budget_status_text_color(is_customized)
    is_customized ? "text-green-900" : "text-blue-900"
  end

  def budget_status_badge_color(is_customized)
    is_customized ? "bg-green-100 text-green-800" : "bg-blue-100 text-blue-800"
  end

  def format_currency(amount)
    amount.nil? ? "--" : number_to_currency(amount)
  end

  def format_percentage(percentage)
    percentage.nil? ? "--%" : "#{percentage}%"
  end

  def budget_status_label(is_customized)
    is_customized ? "Customized" : "Baseline"
  end

  # Calendar view helpers
  def calendar_grid_cell_class(shifts_for_slot)
    classes = "bg-white px-4 py-4 text-sm border-r border-gray-200 min-h-[60px] transition-colors duration-150 cursor-pointer hover:bg-blue-50"
    classes += " bg-blue-50" if shifts_for_slot.any?
    classes
  end

  def shift_badge_class(shift_type = nil)
    "bg-blue-100 border border-blue-200 rounded px-2 py-1 mb-1 text-xs transition-all duration-150 hover:bg-blue-200"
  end

  def shift_text_color
    "text-blue-900 font-medium"
  end

  def shift_type_color(shift_type)
    case shift_type.to_sym
    when :morning
      "bg-amber-50 border-amber-200 text-amber-900"
    when :afternoon
      "bg-blue-50 border-blue-200 text-blue-900"
    when :evening
      "bg-purple-50 border-purple-200 text-purple-900"
    when :night
      "bg-gray-50 border-gray-200 text-gray-900"
    else
      "bg-blue-50 border-blue-200 text-blue-900"
    end
  end

  # Calculate total hours for a staff member in the week
  def staff_total_hours(staff_id, weekly_rosters)
    weekly_rosters.sum do |roster|
      roster.weekly_shifts
            .where(assigned_staff_id: staff_id)
            .sum(&:paid_hours)
    end
  end

  # Check if roster has any shifts assigned
  def has_shifts?(weekly_rosters)
    weekly_rosters.any? { |roster| roster.weekly_shifts.where.not(assigned_staff_id: nil).exists? }
  end

  # Get all unique staff assigned to shifts in rosters
  def assigned_staff_for_rosters(weekly_rosters)
    staff_ids = weekly_rosters.flat_map { |roster|
      roster.weekly_shifts.select(:assigned_staff_id).distinct.pluck(:assigned_staff_id).compact
    }.uniq
    User.where(id: staff_ids).sort_by(&:name)
  end

  # Check if shift has conflicts (for visual warning)
  def shift_has_conflict?(shift, weekly_rosters)
    return false unless shift.assigned_staff_id

    conflicting = WeeklyShift.where(
      assigned_staff_id: shift.assigned_staff_id,
      day_of_week: shift.day_of_week
    ).where.not(id: shift.id)
     .where("start_time < ? AND end_time > ?", shift.end_time, shift.start_time)
     .exists?

    conflicting
  end

  # Format time for display (handles Time and TimeWithZone)
  def format_time(time_obj)
    return "" unless time_obj
    time_obj.strftime("%H:%M")
  end

  # Finalize button state
  def finalize_button_disabled?(weekly_rosters)
    !has_shifts?(weekly_rosters) || weekly_rosters.any?(&:finalized?)
  end
end
