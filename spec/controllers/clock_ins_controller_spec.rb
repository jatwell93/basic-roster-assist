require 'rails_helper'

RSpec.describe ClockInsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_pin) { '1234' }

  before do
    # Set up user with PIN
    user.pin = valid_pin
    user.save!
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid PIN for clock in' do
      let(:clock_in_params) { { pin: valid_pin } }

      it 'creates a new time entry' do
        expect {
          post :create, params: clock_in_params
        }.to change(TimeEntry, :count).by(1)
      end

      it 'redirects to new_clock_in_path' do
        post :create, params: clock_in_params
        expect(response).to redirect_to(new_clock_in_path)
      end

      it 'sets success flash message' do
        post :create, params: clock_in_params
        expect(flash[:notice]).to include('Successfully clocked in')
      end
    end

    context 'with valid PIN for clock out' do
      let(:clock_out_params) { { pin: valid_pin } }
      let!(:existing_entry) do
        create(:time_entry, user: user, clock_in: 8.hours.ago, clock_out: nil)
      end

      it 'updates the existing time entry' do
        expect {
          post :create, params: clock_out_params
        }.to change { existing_entry.reload.clock_out }.from(nil)
      end

      it 'redirects to new_clock_in_path' do
        post :create, params: clock_out_params
        expect(response).to redirect_to(new_clock_in_path)
      end

      it 'sets success flash message with duration' do
        post :create, params: clock_out_params
        expect(flash[:notice]).to include('Successfully clocked out')
        expect(flash[:notice]).to include('hours')
      end
    end

    context 'with invalid PIN' do
      let(:invalid_pin_params) { { pin: '9999' } }

      it 'does not create or update any time entries' do
        expect {
          post :create, params: invalid_pin_params
        }.to_not change(TimeEntry, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_pin_params
        expect(response).to render_template(:new)
      end

      it 'sets error flash message' do
        post :create, params: invalid_pin_params
        expect(flash.now[:alert]).to eq('Invalid PIN')
      end

      it 'returns unprocessable_entity status' do
        post :create, params: invalid_pin_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with blank PIN' do
      let(:blank_pin_params) { { pin: '' } }

      it 'does not create or update any time entries' do
        expect {
          post :create, params: blank_pin_params
        }.to_not change(TimeEntry, :count)
      end

      it 'renders the new template' do
        post :create, params: blank_pin_params
        expect(response).to render_template(:new)
      end

      it 'sets error flash message' do
        post :create, params: blank_pin_params
        expect(flash.now[:alert]).to eq('PIN is required')
      end

      it 'returns unprocessable_entity status' do
        post :create, params: blank_pin_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when already clocked in' do
      let(:already_clocked_in_params) { { pin: valid_pin } }
      let!(:existing_entry) do
        create(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil)
      end

      it 'updates the existing time entry (clock out)' do
        expect {
          post :create, params: already_clocked_in_params
        }.to change { existing_entry.reload.clock_out }.from(nil)
      end

      it 'redirects to new_clock_in_path' do
        post :create, params: already_clocked_in_params
        expect(response).to redirect_to(new_clock_in_path)
      end

      it 'sets success flash message with duration' do
        post :create, params: already_clocked_in_params
        expect(flash[:notice]).to include('Successfully clocked out')
        expect(flash[:notice]).to include('hours')
      end

      it 'returns found status' do
        post :create, params: already_clocked_in_params
        expect(response).to have_http_status(:found)
      end
    end

    context 'when not clocked in but trying to clock out' do
      let(:not_clocked_in_params) { { pin: valid_pin } }

      it 'creates a new time entry (clock in)' do
        expect {
          post :create, params: not_clocked_in_params
        }.to change(TimeEntry, :count).by(1)
      end

      it 'redirects to new_clock_in_path' do
        post :create, params: not_clocked_in_params
        expect(response).to redirect_to(new_clock_in_path)
      end

      it 'sets success flash message' do
        post :create, params: not_clocked_in_params
        expect(flash[:notice]).to include('Successfully clocked in')
      end

      it 'returns found status' do
        post :create, params: not_clocked_in_params
        expect(response).to have_http_status(:found)
      end
    end

    context 'when shift exceeds maximum duration' do
      let(:long_shift_params) { { pin: valid_pin } }
      let!(:long_shift_entry) do
        create(:time_entry, user: user, clock_in: 11.hours.ago, clock_out: nil)
      end

      it 'does not update the time entry' do
        original_clock_out = long_shift_entry.clock_out
        post :create, params: long_shift_params
        expect(long_shift_entry.reload.clock_out).to eq(original_clock_out)
      end

      it 'renders the new template' do
        post :create, params: long_shift_params
        expect(response).to render_template(:new)
      end

      it 'sets error flash message' do
        post :create, params: long_shift_params
        expect(flash.now[:alert]).to eq('Cannot clock out - shift exceeds maximum duration')
      end

      it 'returns unprocessable_entity status' do
        post :create, params: long_shift_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when unexpected error occurs' do
      let(:error_params) { { pin: valid_pin } }

      before do
        allow_any_instance_of(ClockInService).to receive(:clock_in).and_raise(StandardError.new('Database error'))
      end

      it 'renders the new template' do
        post :create, params: error_params
        expect(response).to render_template(:new)
      end

      it 'sets generic error flash message' do
        post :create, params: error_params
        expect(flash.now[:alert]).to eq('An error occurred. Please try again.')
      end

      it 'returns internal_server_error status' do
        post :create, params: error_params
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
