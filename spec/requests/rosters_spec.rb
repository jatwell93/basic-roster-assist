require 'rails_helper'

RSpec.describe "Rosters", type: :request do
  let(:user) { create(:user) }

  # Skip authentication for testing the business logic
  before do
    # Mock the authentication methods to avoid Devise setup issues
    allow_any_instance_of(RostersController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(RostersController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/rosters/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/rosters/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /calendar" do
    let!(:weekly_roster) { create(:weekly_roster, user: user) }
    let!(:weekly_shift) { create(:weekly_shift, weekly_roster: weekly_roster) }

    context "with sales forecast data" do
      let!(:sales_forecast) do
        create(:sales_forecast,
               user: user,
               projected_sales: 1000.0,
               actual_sales: 1200.0,
               start_date: Date.current.beginning_of_week(:monday),
               end_date: Date.current.beginning_of_week(:monday) + 6.days)
      end

      it "calculates and displays sales vs wages percentage" do
        # Mock the RosterCostCalculator to return a known wage cost
        allow_any_instance_of(RosterCostCalculator).to receive(:calculate_total_cost).and_return(240.0)

        get "/rosters/calendar"

        expect(response).to have_http_status(:success)
        # The view should receive the calculated percentage
        # 240 wages / 1200 sales = 20%
        expect(response.body).to include("20.0%")
      end
    end

    context "without sales forecast data" do
      it "handles missing sales data gracefully" do
        get "/rosters/calendar"

        expect(response).to have_http_status(:success)
        # Should show N/A or handle gracefully
      end
    end

    context "with zero sales" do
      let!(:sales_forecast) do
        create(:sales_forecast,
               user: user,
               projected_sales: 0.0,
               actual_sales: nil,
               start_date: Date.current.beginning_of_week(:monday),
               end_date: Date.current.beginning_of_week(:monday) + 6.days)
      end

      it "handles zero sales gracefully" do
        allow_any_instance_of(RosterCostCalculator).to receive(:calculate_total_cost).and_return(100.0)

        get "/rosters/calendar"

        expect(response).to have_http_status(:success)
        # Should show N/A for division by zero
        expect(response.body).to include("N/A")
      end
    end
  end
end
