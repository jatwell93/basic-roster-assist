require 'rails_helper'

RSpec.describe "ClockIns", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/clock_ins/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/clock_ins/create"
      expect(response).to have_http_status(:success)
    end
  end
end
