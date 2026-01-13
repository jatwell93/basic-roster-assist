require 'rails_helper'

RSpec.describe AwardsController, type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, role: :admin) }
  let(:manager_user) { create(:user, role: :manager) }
  let(:staff_user) { create(:user, role: :staff) }
  let(:regular_user) { create(:user, role: :staff) }

  let(:award_rate) { create(:award_rate) }
  let(:user_with_award) { create(:user, award_rates: [ award_rate ]) }
  let(:user_without_award) { create(:user) }
  let(:unassigned_award) { create(:award_rate, user: user_without_award) }

  before(:each) do
    login_as(admin_user, scope: :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  describe 'GET /awards' do
    it 'returns a success response' do
      get awards_path
      expect(response).to be_successful
    end

    it 'assigns the requested award_rates' do
      award_rate # Force creation before request
      get awards_path
      expect(assigns(:award_rates)).to include(award_rate)
    end

    it 'assigns users for the dropdown' do
      manager_user # Force creation
      staff_user
      regular_user
      get awards_path
      expect(assigns(:users)).to include(admin_user, manager_user, staff_user, regular_user)
    end
  end

  describe 'GET /awards/new' do
    it 'returns a success response' do
      get new_award_path
      expect(response).to be_successful
    end

    it 'assigns a new award_rate' do
      get new_award_path
      expect(assigns(:award_rate)).to be_a_new(AwardRate)
    end

    it 'assigns users for the dropdown' do
      manager_user # Force creation
      staff_user
      regular_user
      get new_award_path
      expect(assigns(:users)).to include(admin_user, manager_user, staff_user, regular_user)
    end
  end

  describe 'POST /awards' do
    context 'with valid parameters' do
      it 'creates a new AwardRate' do
        expect {
          post awards_path, params: { award_rate: {
            award_code: 'MA000004',
            classification: 'Level 1',
            rate: 25.50,
            effective_date: Date.current,
            user_id: regular_user.id
          } }
        }.to change(AwardRate, :count).by(1)
      end

      it 'redirects to the awards index' do
        post awards_path, params: { award_rate: {
          award_code: 'MA000004',
          classification: 'Level 1',
          rate: 25.50,
          effective_date: Date.current,
          user_id: regular_user.id
        } }
        expect(response).to redirect_to(awards_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new AwardRate' do
        expect {
          post awards_path, params: { award_rate: {
            award_code: '',
            classification: '',
            rate: -1,
            effective_date: Date.current
          } }
        }.to change(AwardRate, :count).by(0)
      end

      it 'renders the new template' do
        post awards_path, params: { award_rate: {
          award_code: '',
          classification: '',
          rate: -1,
          effective_date: Date.current
        } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /awards/:id/edit' do
    it 'returns a success response' do
      get edit_award_path(award_rate)
      expect(response).to be_successful
    end

    it 'assigns the requested award_rate' do
      get edit_award_path(award_rate)
      expect(assigns(:award_rate)).to eq(award_rate)
    end

    it 'assigns users for the dropdown' do
      get edit_award_path(award_rate)
      expect(assigns(:users)).to include(admin_user, manager_user, staff_user, regular_user)
    end
  end

  describe 'PATCH /awards/:id' do
    context 'with valid parameters' do
      it 'updates the award_rate' do
        patch award_path(award_rate), params: { award_rate: { rate: 30.00 } }
        award_rate.reload
        expect(award_rate.rate).to eq(30.00)
      end

      it 'redirects to the awards index' do
        patch award_path(award_rate), params: { award_rate: { rate: 30.00 } }
        expect(response).to redirect_to(awards_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the award_rate' do
        original_rate = award_rate.rate
        patch award_path(award_rate), params: { award_rate: { rate: -1 } }
        award_rate.reload
        expect(award_rate.rate).to eq(original_rate)
      end

      it 'renders the edit template' do
        patch award_path(award_rate), params: { award_rate: { rate: -1 } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE /awards/:id' do
    it 'destroys the requested award_rate' do
      award_rate # Force creation before test
      expect {
        delete award_path(award_rate)
      }.to change(AwardRate, :count).by(-1)
    end

    it 'redirects to the awards list' do
      delete award_path(award_rate)
      expect(response).to redirect_to(awards_url)
    end
  end

  describe 'GET /awards/users' do
    it 'returns a success response' do
      get users_awards_path
      expect(response).to be_successful
    end

    it 'assigns users with their award rates' do
      manager_user # Force creation
      staff_user
      regular_user
      user_with_award
      user_without_award
      get users_awards_path
      expect(assigns(:users)).to include(admin_user, manager_user, staff_user, regular_user, user_with_award, user_without_award)
    end

    it 'assigns all award rates' do
      get users_awards_path
      expect(assigns(:award_rates)).to include(award_rate)
    end
  end

  describe 'GET /awards/assign_award' do
    it 'returns a success response' do
      get assign_award_awards_path(user_id: user_without_award.id)
      expect(response).to be_successful
    end

    it 'assigns the user' do
      get assign_award_awards_path(user_id: user_without_award.id)
      expect(assigns(:user)).to eq(user_without_award)
    end

    it 'assigns available awards (unassigned)' do
      get assign_award_awards_path(user_id: user_without_award.id)
      expect(assigns(:available_awards)).to be_empty
      expect(assigns(:available_awards)).not_to include(award_rate)
    end

    it 'assigns user awards' do
      get assign_award_awards_path(user_id: user_with_award.id)
      expect(assigns(:user_awards)).to include(award_rate)
    end

    it 'assigns empty user awards for user without awards' do
      get assign_award_awards_path(user_id: user_without_award.id)
      expect(assigns(:user_awards)).to be_empty
    end
  end

  describe 'POST /awards/assign_to_user' do
    context 'when user has no existing assignment for the same award type' do
      let(:different_award) { create(:award_rate, user: nil, award_code: 'MA000005', classification: 'Level 2') }

      it 'assigns the award to the user' do
        post assign_to_user_awards_path, params: { user_id: user_without_award.id, award_rate_id: different_award.id }
        different_award.reload
        expect(different_award.user).to eq(user_without_award)
      end

      it 'redirects to the assign_award page' do
        post assign_to_user_awards_path, params: { user_id: user_without_award.id, award_rate_id: different_award.id }
        expect(response).to redirect_to(assign_award_awards_path(user_id: user_without_award.id))
      end

      it 'shows success notice' do
        post assign_to_user_awards_path, params: { user_id: user_without_award.id, award_rate_id: different_award.id }
        expect(flash[:notice]).to eq('Award assigned successfully.')
      end
    end

    context 'when user already has an assignment for the same award type' do
      let(:temp_user) { create(:user) }
      let(:existing_award) { create(:award_rate, user: user_with_award, award_code: 'MA000004', classification: 'Level 1') }
      let(:new_award) { create(:award_rate, user: temp_user, award_code: 'MA000004', classification: 'Level 1') }

      it 'removes the existing assignment before assigning the new one' do
        existing_award # Force creation
        new_award
        post assign_to_user_awards_path, params: { user_id: user_with_award.id, award_rate_id: new_award.id }
        existing_award.reload
        new_award.reload
        expect(existing_award.user).to be_nil
        expect(new_award.user).to eq(user_with_award)
      end
    end
  end

  describe 'DELETE /awards/remove_from_user' do
    it 'removes the award assignment from the user' do
      user_with_award # Force creation
      award_rate
      delete remove_from_user_awards_path, params: { user_id: user_with_award.id, award_rate_id: award_rate.id }
      award_rate.reload
      expect(award_rate.user).to be_nil
    end

    it 'redirects to the assign_award page' do
      delete remove_from_user_awards_path, params: { user_id: user_with_award.id, award_rate_id: award_rate.id }
      expect(response).to redirect_to(assign_award_awards_path(user_id: user_with_award.id))
    end

    it 'shows success notice' do
      delete remove_from_user_awards_path, params: { user_id: user_with_award.id, award_rate_id: award_rate.id }
      expect(flash[:notice]).to eq('Award assignment removed.')
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      before do
        Warden.test_reset!
        login_as(staff_user, scope: :user)
      end

      after do
        Warden.test_reset!
      end

      it 'redirects to root path for index' do
        get awards_path
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for new' do
        get new_award_path
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for create' do
        post awards_path, params: { award_rate: { award_code: 'MA000004', classification: 'Level 1', rate: 25.50, effective_date: Date.current } }
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for edit' do
        get edit_award_path(award_rate)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for update' do
        patch award_path(award_rate), params: { award_rate: { rate: 30.00 } }
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for destroy' do
        delete award_path(award_rate)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for users' do
        get users_awards_path
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for assign_award' do
        get assign_award_awards_path(user_id: user_without_award.id)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for assign_to_user' do
        post assign_to_user_awards_path, params: { user_id: user_without_award.id, award_rate_id: award_rate.id }
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root path for remove_from_user' do
        delete remove_from_user_awards_path, params: { user_id: user_with_award.id, award_rate_id: award_rate.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
