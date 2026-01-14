require 'rails_helper'

RSpec.describe "BaseShifts Multi-Creation", type: :request do
  include Warden::Test::Helpers

  let(:user) { create(:user, role: :manager) }
  let(:roster) { create(:base_roster, user: user) }
  let(:work_section) { create(:work_section, user: user) }

  before do
    login_as(user, scope: :user)
  end

  describe "POST #create_multi" do
    context "with valid shifts" do
      let(:valid_shifts_params) do
        {
          "0" => {
            day_of_week: "monday",
            start_time: "09:00",
            end_time: "17:00",
            work_section_id: work_section.id
          },
          "1" => {
            day_of_week: "tuesday",
            start_time: "10:00",
            end_time: "18:00",
            work_section_id: work_section.id
          }
        }
      end

      it "creates all shifts and redirects with success message" do
        expect {
          post create_multi_roster_base_shifts_path(roster), params: { shifts: valid_shifts_params }
        }.to change(BaseShift, :count).by(2)

        expect(response).to redirect_to(roster_path(roster))
        expect(flash[:notice]).to include("Successfully created 2 shifts")
      end
    end

    context "with invalid shifts" do
      let(:invalid_shifts_params) do
        {
          "0" => {
            day_of_week: "monday",
            start_time: "17:00",
            end_time: "09:00", # Invalid: end before start (not overnight)
            work_section_id: work_section.id
          },
          "1" => {
            day_of_week: "tuesday",
            start_time: "", # Invalid: missing start time
            end_time: "18:00",
            work_section_id: work_section.id
          }
        }
      end

      it "does not create any shifts" do
        expect {
          post create_multi_roster_base_shifts_path(roster), params: { shifts: invalid_shifts_params }
        }.not_to change(BaseShift, :count)
      end

      it "renders new_multi template" do
        post create_multi_roster_base_shifts_path(roster), params: { shifts: invalid_shifts_params }
        expect(response).to render_template(:new_multi)
      end

      it "returns unprocessable_entity status" do
        post create_multi_roster_base_shifts_path(roster), params: { shifts: invalid_shifts_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "preserves user input in response body" do
        post create_multi_roster_base_shifts_path(roster), params: { shifts: invalid_shifts_params }
        expect(response.body).to include("17:00") # start_time from first shift
        expect(response.body).to include("18:00") # end_time from second shift
      end

      it "displays validation errors in response" do
        post create_multi_roster_base_shifts_path(roster), params: { shifts: invalid_shifts_params }
        expect(response.body).to include("must") # error message fragment
      end
    end

    context "with mixed valid and invalid shifts" do
      let(:mixed_shifts_params) do
        {
          "0" => {
            day_of_week: "monday",
            start_time: "09:00",
            end_time: "17:00",
            work_section_id: work_section.id
          },
          "1" => {
            day_of_week: "tuesday",
            start_time: "", # Invalid
            end_time: "18:00",
            work_section_id: work_section.id
          }
        }
      end

      it "does not create any shifts (all-or-nothing)" do
        expect {
          post create_multi_roster_base_shifts_path(roster), params: { shifts: mixed_shifts_params }
        }.not_to change(BaseShift, :count)
      end

      it "renders new_multi with errors" do
        post create_multi_roster_base_shifts_path(roster), params: { shifts: mixed_shifts_params }
        expect(response).to render_template(:new_multi)
        expect(response.body).to include("09:00") # valid shift data preserved
      end
    end
  end
end
