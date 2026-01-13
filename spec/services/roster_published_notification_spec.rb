require 'rails_helper'

RSpec.describe RosterPublishedNotification do
  let(:user) { create(:user, email: 'staff@example.com') }
  let(:roster) { create(:base_roster, user: user) }
  let(:service) { described_class.new(roster) }

  describe '#initialize' do
    it 'accepts a roster parameter' do
      expect { described_class.new(roster) }.not_to raise_error
    end

    it 'raises error for nil roster' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError, 'Roster cannot be nil')
    end
  end

  describe '#call' do
    let(:mock_mailer) { double('RosterMailer') }
    let(:mock_delivery) { double('delivery', deliver_later: true) }

    before do
      allow(RosterMailer).to receive(:roster_published).and_return(mock_delivery)
    end

    context 'when roster has associated user' do
      it 'sends email notification successfully' do
        expect(RosterMailer).to receive(:roster_published).with(roster).and_return(mock_delivery)
        expect(mock_delivery).to receive(:deliver_later)

        result = service.call
        expect(result).to be_success
        expect(result.roster).to eq(roster)
      end

      it 'handles email delivery failures gracefully' do
        allow(mock_delivery).to receive(:deliver_later).and_raise(StandardError.new('SMTP error'))

        result = service.call
        expect(result).to be_success # Service succeeds even if email fails
        expect(result.roster).to eq(roster)
      end
    end

    context 'when roster has no associated user' do
      # Since base_rosters.user_id is NOT NULL, we simulate the error condition
      # by using a roster object whose user association returns nil
      let(:roster_without_user) do
        roster = create(:base_roster, user: user)
        allow(roster).to receive(:user).and_return(nil)
        roster
      end
      let(:service_without_user) { described_class.new(roster_without_user) }

      it 'raises RosterPublishedNotification::NoUserError' do
        expect {
          service_without_user.call
        }.to raise_error(RosterPublishedNotification::NoUserError, 'Roster has no associated user')
      end
    end

    context 'when roster is nil' do
      let(:service_with_nil) { described_class.new(nil) }

      it 'raises ArgumentError during initialization' do
        expect { service_with_nil }.to raise_error(ArgumentError, 'Roster cannot be nil')
      end
    end

    # Removed: User model requires email, can't create user without it
  end

  describe 'error classes' do
    it 'defines NoUserError' do
      expect(described_class::NoUserError).to be < StandardError
    end
  end

  describe 'service result' do
    it 'returns a successful result with roster' do
      allow(RosterMailer).to receive_message_chain(:roster_published, :deliver_later)

      result = service.call
      expect(result.success?).to be true
      expect(result.roster).to eq(roster)
    end
  end
end
