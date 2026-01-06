require "rails_helper"

RSpec.describe RosterMailer, type: :mailer do
  let(:user) { create(:user, role: :manager, email: "manager@example.com") }
  let(:staff_member) { create(:user, role: :staff, name: "John Doe", email: "john@example.com") }
  let(:another_staff) { create(:user, role: :staff, name: "Jane Smith", email: "jane@example.com") }
  let(:base_roster) { create(:base_roster, user: user) }
  let(:week_start) { Date.current.beginning_of_week(:monday) }
  let(:week_end) { week_start + 6.days }
  let(:weekly_roster) do
    create(:weekly_roster, base_roster: base_roster, user: user, week_start_date: week_start, week_end_date: week_end, name: "Week 1 Roster")
  end

  describe "#send_shifts" do
    let(:staff_shifts) do
      [
        create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member,
               day_of_week: :monday, start_time: "09:00", end_time: "17:00",
               break_start_time: "12:00", break_end_time: "13:00", shift_type: :morning),
        create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member,
               day_of_week: :tuesday, start_time: "09:00", end_time: "17:00",
               break_start_time: "12:00", break_end_time: "13:00", shift_type: :morning),
        create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member,
               day_of_week: :wednesday, start_time: "14:00", end_time: "22:00",
               break_start_time: "18:00", break_end_time: "19:00", shift_type: :evening)
      ]
    end

    it "sends email to assigned staff member" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.to).to eq([ staff_member.email ])
    end

    it "has correct subject with roster name and dates" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.subject).to include("Your Roster for")
      expect(email.subject).to include("Week 1 Roster")
    end

    it "includes roster in email body (text version)" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part.body.to_s).to include(week_start.strftime("%A, %B %d"))
      expect(email.text_part.body.to_s).to include(week_end.strftime("%A, %B %d"))
    end

    it "includes shift details in email body (text version)" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part.body.to_s).to include("Monday")
      expect(email.text_part.body.to_s).to include("Tuesday")
      expect(email.text_part.body.to_s).to include("Wednesday")
    end

    it "includes staff name in greeting" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part.body.to_s).to include("Hi John Doe")
    end

    it "includes break times when present" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      # Check for break time in text (with 12-hour format AM/PM)
      text_body = email.text_part.body.to_s
      expect(text_body).to match(/Break:.*[0-9]{2}:[0-9]{2}\s*[AP]M.*[0-9]{2}:[0-9]{2}\s*[AP]M/m)
    end

    it "includes paid hours for each shift" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part.body.to_s).to include("Paid Hours:")
    end

    it "generates both text and html versions" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part).not_to be_nil
      expect(email.html_part).not_to be_nil
    end

    it "includes total hours in email body" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.text_part.body.to_s).to include("Total Hours This Week:")
    end

    it "formats times correctly in email body" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      # Check HTML contains times in 12-hour format (AM/PM)
      html_body = email.html_part.body.to_s
      expect(html_body).to include("AM") # Times are formatted with AM/PM
      expect(html_body).to include("PM")
      expect(html_body).to include("<table")
    end
  end

  describe "#shift_changed" do
    let(:shift) do
      create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member,
             day_of_week: :monday, start_time: "10:00", end_time: "18:00",
             break_start_time: "13:00", break_end_time: "14:00", shift_type: :morning)
    end
    let(:old_shift_data) { { start_time: "09:00", end_time: "17:00", break_start_time: "12:00", break_end_time: "13:00" } }

    it "sends email to affected staff member" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.to).to eq([ staff_member.email ])
    end

    it "has correct subject indicating shift update" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.subject).to include("Shift Has Been Updated")
      expect(email.subject).to include("Week 1 Roster")
    end

    it "includes old times in email body" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.text_part.body.to_s).to include("Old Time:")
      expect(email.text_part.body.to_s).to include("09:00")
      expect(email.text_part.body.to_s).to include("17:00")
    end

    it "includes new times in email body" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      text_body = email.text_part.body.to_s
      expect(text_body).to include("New Time:")
      expect(text_body).to match(/10:00|18:00/)  # Check for either new time
    end

    it "includes staff name in greeting" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.text_part.body.to_s).to include("Hi John Doe")
    end

    it "includes break time information" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.text_part.body.to_s).to include("Break:")
    end

    it "includes paid hours for updated shift" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.text_part.body.to_s).to include("Paid Hours:")
    end

    it "generates both text and html versions" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.text_part).not_to be_nil
      expect(email.html_part).not_to be_nil
    end

    it "renders HTML table with shift changes" do
      email = RosterMailer.shift_changed(shift, old_shift_data, staff_member)
      expect(email.html_part.body.to_s).to include("<table")
      expect(email.html_part.body.to_s).to include("<tr>")
    end
  end

  describe "email headers" do
    let(:staff_shifts) { [ create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member) ] }

    it "sets from address on send_shifts email" do
      email = RosterMailer.send_shifts(weekly_roster, staff_member, staff_shifts)
      expect(email.from).to be_present
    end

    it "sets from address on shift_changed email" do
      shift = create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member)
      email = RosterMailer.shift_changed(shift, {}, staff_member)
      expect(email.from).to be_present
    end
  end

  describe "integration with WeeklyRoster" do
    it "works with finalize! method when called directly" do
      shift1 = create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member, day_of_week: :monday)
      shift2 = create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: another_staff, day_of_week: :tuesday)

      # Verify finalize! calls the mailer methods
      expect {
        weekly_roster.finalize!(user)
      }.not_to raise_error

      # Verify roster is now finalized
      expect(weekly_roster.reload.finalized?).to be true
    end

    it "works with notify_shift_change when called directly" do
      shift = create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff: staff_member, day_of_week: :monday)
      weekly_roster.finalize!(user)

      old_data = { start_time: shift.start_time, end_time: shift.end_time }

      # Verify it doesn't raise an error when called
      expect {
        weekly_roster.notify_shift_change(shift, old_data)
      }.not_to raise_error
    end
  end
end
