require 'rails_helper'

RSpec.describe AwardsController, type: :controller do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:award_rate) { create(:award_rate) }

  before do
    sign_in admin_user
  end

  describe 'GET #users' do
    let!(:user_with_awards) { create(:user) }
    let!(:user_without_awards) { create(:user) }
    let!(:award1) { create(:award_rate, user: user_with_awards) }
    let!(:award2) { create(:award_rate, user: user_with_awards) }

    before do
      get :users
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @users with users including their award rates' do
      expect(assigns(:users)).to include(user_with_awards)
      expect(assigns(:users)).to include(user_without_awards)
    end

    it 'assigns @award_rates with all award rates' do
      expect(assigns(:award_rates)).to include(award1)
      expect(assigns(:award_rates)).to include(award2)
    end

    it 'orders users by name' do
      # This test assumes users are ordered by name in the controller
      # Adjust based on actual implementation
      expect(assigns(:users).first.name).to be <= assigns(:users).last.name
    end

    it 'renders the users template' do
      expect(response).to render_template(:users)
    end
  end

  describe 'authentication and authorization' do
    context 'when user is not authenticated' do
      before do
        sign_out admin_user
        get :users
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not an admin' do
      before do
        sign_out admin_user
        sign_in regular_user
        get :users
      end

      it 'redirects with access denied message' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include('Access denied')
      end
    end
  end
end
