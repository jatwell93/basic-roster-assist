require 'rails_helper'

RSpec.describe "WorkSections", type: :request do
  include Warden::Test::Helpers

  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  after do
    Warden.test_reset!
  end

  describe "GET /work_sections" do
    it "shows only current user's sections" do
      create(:work_section, user: user, name: "Dispensary")
      other = create(:user, email: "other@example.com")
      create(:work_section, user: other, name: "Backroom")

      get work_sections_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dispensary")
      expect(response.body).not_to include("Backroom")
    end
  end

  describe "POST /work_sections" do
    it "creates a section for the current user" do
      expect {
        post work_sections_path, params: { work_section: { name: "Front of Shop" } }
      }.to change { user.work_sections.count }.by(1)

      expect(response).to redirect_to(work_sections_path)
    end

    it "renders errors when invalid" do
      post work_sections_path, params: { work_section: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      # HTML entities are encoded, check for the actual rendered error
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "PATCH /work_sections/:id" do
    it "updates a section" do
      section = create(:work_section, user: user, name: "Cosmetics")

      patch work_section_path(section), params: { work_section: { name: "Beauty" } }

      expect(response).to redirect_to(work_sections_path)
      expect(section.reload.name).to eq("Beauty")
    end
  end

  describe "DELETE /work_sections/:id" do
    it "deletes a section" do
      section = create(:work_section, user: user)

      expect {
        delete work_section_path(section)
      }.to change { WorkSection.count }.by(-1)

      expect(response).to redirect_to(work_sections_path)
    end
  end

  describe "authorization" do
    it "prevents accessing another user's section" do
      other = create(:user, email: "other@example.com")
      section = create(:work_section, user: other)

      # When trying to access another user's section, Rails rescues RecordNotFound
      # and returns 404. The controller scoped query raises the exception internally.
      delete work_section_path(section)

      expect(response).to have_http_status(:not_found)
    end
  end
end
