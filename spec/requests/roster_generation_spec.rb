require 'rails_helper'

RSpec.describe "RosterGeneration", type: :request do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  let(:base_roster) { create(:base_roster, user: user) }
  let(:next_monday) { Date.today.beginning_of_week(:monday).next_week }

  before do
    login_as(user, scope: :user)
  end
  
  after do 
    Warden.test_reset! 
  end

  describe "POST /rosters/:id/generate" do
    before do
       create(:base_shift, base_roster: base_roster)
    end

    context "with valid params" do
      it "generates a weekly roster and redirects to calendar" do
        expect {
          post generate_roster_path(base_roster), params: { week_start_date: next_monday }
        }.to change(WeeklyRoster, :count).by(1)

        weekly_roster = WeeklyRoster.last
        expect(weekly_roster.week_start_date).to eq(next_monday)
        expect(weekly_roster.base_roster).to eq(base_roster)

        expect(response).to redirect_to(calendar_rosters_path(week_start: next_monday))
        follow_redirect!
        expect(response.body).to include("Weekly roster generated successfully")
      end
    end

    context "when week is not a Monday" do
      it "redirects back with error" do
        not_monday = next_monday + 1.day
        expect {
          post generate_roster_path(base_roster), params: { week_start_date: not_monday }
        }.not_to change(WeeklyRoster, :count)

        expect(response).to redirect_to(roster_path(base_roster))
        follow_redirect!
        expect(response.body).to include("Week start date must be a Monday")
      end
    end
    
    context "when empty date" do
       it "redirects back with error" do
        expect {
          post generate_roster_path(base_roster), params: { week_start_date: "" }
        }.not_to change(WeeklyRoster, :count)

        expect(response).to redirect_to(roster_path(base_roster))
        follow_redirect!
        expect(response.body).to include("Please select a week start date")
       end
    end

    context "when roster already exists" do
      before do
        create(:weekly_roster, base_roster: base_roster, user: user, week_start_date: next_monday, week_end_date: next_monday + 6.days)
      end
      
      it "does not duplicate and redirects with error" do
        expect {
          post generate_roster_path(base_roster), params: { week_start_date: next_monday }
        }.not_to change(WeeklyRoster, :count)

        expect(response).to redirect_to(roster_path(base_roster))
        follow_redirect!
        expect(response.body).to include("already exists")
      end
    end
  end
end
