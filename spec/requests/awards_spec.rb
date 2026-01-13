require 'rails_helper'

RSpec.describe "Awards", type: :request do
  include Warden::Test::Helpers
  
  let(:admin_user) { create(:user, role: :admin) }
  
  before do
    login_as(admin_user, scope: :user)
  end
  
  describe "GET /awards" do
    it "returns http success" do
      get awards_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /awards/new" do
    it "returns http success" do
      get new_award_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /awards" do
    it "creates an award rate" do
      post awards_path, params: { award_rate: { name: 'Test Award', base_rate: 25.0, award_code: 'MA000001', classification: 'Level 1', rate: 25.0, effective_date: Date.current } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /awards/:id/edit" do
    let(:award_rate) { create(:award_rate, user: admin_user) }
    
    it "returns http success" do
      get edit_award_path(award_rate)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /awards/:id" do
    let(:award_rate) { create(:award_rate, user: admin_user) }
    
    it "updates the award" do
      patch award_path(award_rate), params: { award_rate: { name: 'Updated Award' } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /awards/:id" do
    let(:award_rate) { create(:award_rate, user: admin_user) }
    
    it "destroys the award" do
      delete award_path(award_rate)
      expect(response).to have_http_status(:redirect)
    end
  end
end
