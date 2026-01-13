require 'rails_helper'

RSpec.describe ClockInService, type: :service do
  let(:user) { create(:user, hourly_rate: 25.50) }
  let(:valid_pin) { '1234' }

  before do
    # Mock the PIN verification - we'll implement this later
    allow_any_instance_of(User).to receive(:valid_pin?).with(valid_pin).and_return(true)
  end

  describe '#initialize' do
    context 'with valid user and pin' do
      it 'initializes successfully' do
        service = described_class.new(user: user, pin: valid_pin)
        expect(service.instance_variable_get(:@user)).to eq(user)
        expect(service.instance_variable_get(:@pin)).to eq(valid_pin)
      end
    end

    context 'with invalid parameters' do
      it 'raises error when user is nil' do
        expect {
          described_class.new(user: nil, pin: valid_pin)
        }.to raise_error(ArgumentError, 'User is required')
      end

      it 'raises error when pin is nil' do
        expect {
          described_class.new(user: user, pin: nil)
        }.to raise_error(ArgumentError, 'PIN is required')
      end
    end
  end

  describe '#clock_in' do
    context 'when user is not currently clocked in' do
      it 'creates a new time entry' do
        service = described_class.new(user: user, pin: valid_pin)

        expect {
          result = service.clock_in
          expect(result).to be_a(TimeEntry)
          expect(result.user).to eq(user)
          expect(result.clock_in).to be_present
          expect(result.clock_out).to be_nil
        }.to change(TimeEntry, :count).by(1)
      end

      it 'returns the created time entry' do
        service = described_class.new(user: user, pin: valid_pin)
        result = service.clock_in

        expect(result).to be_a(TimeEntry)
        expect(result.persisted?).to be true
        expect(result.ongoing?).to be true
      end
    end

    context 'when user is already clocked in' do
      let!(:existing_entry) { create(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil) }

      it 'raises an error' do
        service = described_class.new(user: user, pin: valid_pin)

        expect {
          service.clock_in
        }.to raise_error(ClockInService::AlreadyClockedInError, 'User is already clocked in')
      end

      it 'does not create a new time entry' do
        service = described_class.new(user: user, pin: valid_pin)

        expect {
          begin
            service.clock_in
          rescue
            # Expected error
          end
        }.not_to change(TimeEntry, :count)
      end
    end

    context 'when PIN is invalid' do
      before do
        allow_any_instance_of(User).to receive(:valid_pin?).with('wrong').and_return(false)
      end

      it 'raises an error' do
        service = described_class.new(user: user, pin: 'wrong')

        expect {
          service.clock_in
        }.to raise_error(ClockInService::InvalidPinError, 'Invalid PIN provided')
      end
    end
  end

  describe '#clock_out' do
    context 'when user has an ongoing time entry' do
      let!(:ongoing_entry) { create(:time_entry, user: user, clock_in: 2.hours.ago, clock_out: nil) }

      it 'completes the ongoing time entry' do
        service = described_class.new(user: user, pin: valid_pin)

        result = service.clock_out

        expect(result).to eq(ongoing_entry)
        expect(result.clock_out).to be_present
        expect(result.ongoing?).to be false
        expect(result.completed?).to be true
      end

      it 'returns the completed time entry' do
        service = described_class.new(user: user, pin: valid_pin)
        result = service.clock_out

        expect(result).to be_a(TimeEntry)
        expect(result.persisted?).to be true
        expect(result.completed?).to be true
      end
    end

    context 'when user is not clocked in' do
      it 'raises an error' do
        service = described_class.new(user: user, pin: valid_pin)

        expect {
          service.clock_out
        }.to raise_error(ClockInService::NotClockedInError, 'User is not currently clocked in')
      end
    end

    context 'when PIN is invalid' do
      let!(:ongoing_entry) { create(:time_entry, user: user, clock_in: 2.hours.ago, clock_out: nil) }

      before do
        allow_any_instance_of(User).to receive(:valid_pin?).with('wrong').and_return(false)
      end

      it 'raises an error' do
        service = described_class.new(user: user, pin: 'wrong')

        expect {
          service.clock_out
        }.to raise_error(ClockInService::InvalidPinError, 'Invalid PIN provided')
      end

      it 'does not complete the time entry' do
        service = described_class.new(user: user, pin: 'wrong')

        begin
          service.clock_out
        rescue
          # Expected error
        end

        ongoing_entry.reload
        expect(ongoing_entry.clock_out).to be_nil
        expect(ongoing_entry.ongoing?).to be true
      end
    end
  end

  describe 'business rules' do
    context 'maximum shift duration' do
      let!(:long_entry) { create(:time_entry, user: user, clock_in: 11.hours.ago, clock_out: nil) }

      it 'prevents clocking out after maximum hours' do
        # Test that shift exceeding 10 hours raises error
        service = described_class.new(user: user, pin: valid_pin)

        expect {
          service.clock_out
        }.to raise_error(ClockInService::ShiftTooLongError, 'Shift exceeds maximum duration of 10 hours')
      end
    end
  end
end
