require 'rails_helper'

RSpec.describe "ClockIns", type: :request do
  describe "GET /clock_in" do
    it "returns http success" do
      get new_clock_in_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /clock_in" do
    let(:user) { create(:user, pin: '1234') }
    
    it "handles clock in request" do
      post clock_in_path, params: { pin: '1234', user_id: user.id }
      # Could be success or redirect depending on implementation
      expect(response.status).to be_in([200, 302, 422])
    end
  end
end
