require "rails_helper"

RSpec.describe "Rosters Calendar Functionality", type: :model do
  let(:user) { create(:user, role: :manager) }
  let(:staff_member) { create(:user, role: :staff) }
  let(:base_roster) { create(:base_roster, user: user) }
  let(:weekly_roster) { create(:weekly_roster, user: user, base_roster: base_roster) }

  describe "WeeklyShift Validations" do
    it "creates a valid shift with 15-minute intervals" do
      shift = create(:weekly_shift, weekly_roster: weekly_roster, assigned_staff_id: staff_member.id)
      expect(shift).to be_valid
    end

    it "rejects shifts with non-15-minute-interval times" do
      shift = build(:weekly_shift, weekly_roster: weekly_roster, assigned_staff_id: staff_member.id, start_time: "09:07")
      expect(shift).not_to be_valid
      expect(shift.errors[:base]).to include(/15-minute intervals/)
    end

    it "prevents overlapping shifts for same staff" do
      # Create first shift
      create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "13:00", assigned_staff_id: staff_member.id)

      # Try to create overlapping shift
      shift = build(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "12:00", end_time: "15:00", assigned_staff_id: staff_member.id)
      expect(shift).not_to be_valid
      expect(shift.errors[:base]).to include(/already has a shift/)
    end

    it "allows multiple shifts for different staff on same time" do
      other_staff = create(:user, role: :staff)
      
      create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", assigned_staff_id: staff_member.id)

      shift = build(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", assigned_staff_id: other_staff.id)
      expect(shift).to be_valid
    end
  end

  describe "WeeklyShift Break Time Calculations" do
    it "calculates paid hours excluding breaks" do
      shift = create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", break_start_time: "12:00", break_end_time: "12:30", assigned_staff_id: staff_member.id)
      # 8 hours - 0.5 hour break = 7.5 hours
      expect(shift.paid_hours).to eq(7.5)
    end

    it "calculates wage cost based on paid hours and hourly rate" do
      staff_member.update(hourly_rate: 20.00)
      shift = create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", break_start_time: "12:00", break_end_time: "12:30", assigned_staff_id: staff_member.id)
      # 7.5 hours * $20 = $150
      expect(shift.wage_cost).to eq(150.0)
    end
  end

  describe "WeeklyRoster Finalization" do
    it "marks roster as finalized" do
      create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", assigned_staff_id: staff_member.id)
      weekly_roster.finalize!(user)
      expect(weekly_roster.reload.finalized?).to be true
      expect(weekly_roster.finalized_at).to be_present
      expect(weekly_roster.finalized_by).to eq(user)
    end

    it "allows editing even after finalization" do
      shift = create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", assigned_staff_id: staff_member.id)
      weekly_roster.finalize!(user)
      # Should still be able to update
      shift.update(end_time: "18:00")
      expect(shift.reload.end_time.strftime("%H:%M")).to eq("18:00")
    end
  end

  describe "Shift Scopes" do
    before do
      create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "09:00", end_time: "17:00", assigned_staff_id: staff_member.id)
      other_staff = create(:user, role: :staff)
      create(:weekly_shift, weekly_roster: weekly_roster, day_of_week: :monday, start_time: "18:00", end_time: "22:00", assigned_staff_id: other_staff.id)
    end

    it "filters shifts by day" do
      monday_shifts = WeeklyShift.by_day(:monday)
      expect(monday_shifts.count).to eq(2)
    end

    it "filters shifts by staff" do
      staff_shifts = WeeklyShift.for_staff(staff_member.id)
      expect(staff_shifts.count).to eq(1)
      expect(staff_shifts.first.start_time.strftime("%H:%M")).to eq("09:00")
    end
  end
end
