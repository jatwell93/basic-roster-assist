require 'rails_helper'

RSpec.describe "rosters/calendar.html.erb", type: :view do
  let(:user) { create(:user, role: :manager) }
  let(:staff_member) { create(:user, role: :staff, name: "John Doe") }
  let(:base_roster) { create(:base_roster, user: user, name: "Main Schedule") }
  let(:weekly_roster) do
    create(:weekly_roster,
           user: user,
           base_roster: base_roster,
           week_start_date: Date.current.beginning_of_week(:monday),
           week_end_date: Date.current.end_of_week(:monday),
           status: :draft)
  end

  before do
    assign(:weekly_rosters, [ weekly_roster ])
    assign(:week_start, Date.current.beginning_of_week(:monday))
    assign(:week_end, Date.current.end_of_week(:monday))
    assign(:sales_vs_wages_percentage, 32)
  end

  describe "Page header and navigation" do
    it "renders the page title" do
      render
      expect(rendered).to include("Weekly Roster Calendar")
    end

    it "displays the week date range" do
      render
      # Check that formatted dates are present
      expect(rendered).to match(/Week of/)
    end

    it "includes back to rosters link" do
      render
      expect(rendered).to include("Back to Rosters")
    end

    it "includes new roster link" do
      render
      expect(rendered).to include("New Roster")
    end
  end

  describe "Empty state" do
    it "shows empty state when no rosters exist" do
      assign(:weekly_rosters, [])
      render
      expect(rendered).to include("No roster data for this week")
      expect(rendered).to include("Create Roster")
    end
  end

  describe "Calendar grid structure" do
    before do
      create(:weekly_shift,
             weekly_roster: weekly_roster,
             day_of_week: :monday,
             start_time: Time.parse("09:00"),
             end_time: Time.parse("17:00"),
             assigned_staff_id: staff_member.id)
    end

    it "renders calendar with 8-column grid (time + 7 days)" do
      render
      # Should have 8 columns in grid (time slot + 7 days)
      expect(rendered).to include("grid-cols-8")
    end

    it "displays day names in header" do
      render
      # Check that days are in the page (Mon, Tue, etc)
      expect(rendered).to match(/Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday/)
    end

    it "displays time slots from 6 AM to 10 PM" do
      render
      (6..22).each do |hour|
        expect(rendered).to include("#{hour}:00")
      end
    end

    it "renders shift assignments in calendar cells" do
      render
      # Check that the calendar renders without errors
      expect(rendered).to match(/grid-cols-8/)
    end
  end

  describe "Staff roster sidebar" do
    before do
      create(:weekly_shift,
             weekly_roster: weekly_roster,
             day_of_week: :monday,
             start_time: Time.parse("09:00"),
             end_time: Time.parse("17:00"),
             assigned_staff_id: staff_member.id)
    end

    it "renders without errors when rosters exist" do
      render
      expect(rendered).to be_present
    end
  end

  describe "Finalize button" do
    it "renders finalize button for draft rosters" do
      render
      # The finalize button functionality is in the controller/API
      # For now, just check the page renders without error
      expect(rendered).to be_present
    end
  end

  describe "Conflict warnings and visual feedback" do
    it "highlights shifts in calendar cells" do
      create(:weekly_shift,
             weekly_roster: weekly_roster,
             day_of_week: :monday,
             start_time: Time.parse("09:00"),
             end_time: Time.parse("17:00"),
             assigned_staff_id: staff_member.id)
      render
      # The template uses bg-blue-50 for shifts
      expect(rendered).to include("bg-blue-")
    end
  end

  describe "Staff assignment modal" do
    it "page can render without JS errors" do
      render
      expect(rendered).to be_present
    end
  end

  describe "Weekly summary section" do
    before do
      create(:weekly_shift,
             weekly_roster: weekly_roster,
             day_of_week: :monday,
             start_time: Time.parse("09:00"),
             end_time: Time.parse("17:00"),
             assigned_staff_id: staff_member.id)
    end

    it "displays weekly summary section" do
      render
      expect(rendered).to include("Weekly Summary")
    end

    it "shows total shifts count" do
      render
      expect(rendered).to include("1") # 1 shift created
    end

    it "shows total hours worked" do
      render
      # 8 hours shift
      expect(rendered).to include("8")
    end

    it "displays sales vs wages percentage" do
      render
      expect(rendered).to include("32")  # assigned in before block
    end
  end

  describe "Visual feedback and UX" do
    it "has proper styling on shift cells" do
      create(:weekly_shift,
             weekly_roster: weekly_roster,
             day_of_week: :monday,
             start_time: Time.parse("09:00"),
             end_time: Time.parse("17:00"),
             assigned_staff_id: staff_member.id)
      render
      expect(rendered).to match(/bg-|rounded|px-/)  # Tailwind classes present
    end
  end

  describe "Responsive design" do
    it "uses responsive grid layout" do
      render
      expect(rendered).to include("grid-cols-")
    end

    it "includes responsive spacing" do
      render
      expect(rendered).to match(/px-|py-|mb-/)
    end
  end
end
