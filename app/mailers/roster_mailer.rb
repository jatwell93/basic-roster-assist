class RosterMailer < ApplicationMailer
  def roster_published(roster)
    @roster = roster
    @user = roster.user

    mail(
      to: @user.email,
      subject: "New Roster Published - #{roster.name}"
    )
  end

  # Notify staff of assigned shifts when roster is finalized
  def send_shifts(weekly_roster, staff, staff_shifts)
    @weekly_roster = weekly_roster
    @staff = staff
    @staff_shifts = staff_shifts
    @week_start = weekly_roster.week_start_date.strftime("%A, %B %d")
    @week_end = weekly_roster.week_end_date.strftime("%A, %B %d")
    @total_hours = staff_shifts.sum(&:paid_hours)

    mail(
      to: staff.email,
      subject: "Your Roster for #{@week_start} to #{@week_end} - #{weekly_roster.name}"
    )
  end

  # Notify staff of changes to finalized roster
  def shift_changed(shift, old_shift_data, staff)
    @shift = shift
    @old_shift_data = old_shift_data
    @staff = staff
    @weekly_roster = shift.weekly_roster

    mail(
      to: staff.email,
      subject: "Your Shift Has Been Updated - #{@weekly_roster.name}"
    )
  end
end
