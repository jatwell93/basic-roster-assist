require 'rails_helper'

RSpec.describe RosterCostCalculator, type: :service do
  let(:user) { create(:user, hourly_rate: 25.50) }
  let(:other_user) { create(:user, hourly_rate: 30.00) }
  let(:roster) { create(:base_roster, user: user) }

  describe '#calculate_total_cost' do
    context 'when roster has shifts with assigned users' do
      before do
        # Create shifts for the roster on different days
        create(:base_shift,
                base_roster: roster,
                day_of_week: 'monday',
                start_time: '09:00',
                end_time: '17:00') # 8 hours

        create(:base_shift,
                base_roster: roster,
                day_of_week: 'tuesday',
                start_time: '09:00',
                end_time: '13:00') # 4 hours

        create(:base_shift,
                base_roster: roster,
                day_of_week: 'wednesday',
                start_time: '14:00',
                end_time: '22:00') # 8 hours
      end

      it 'calculates total cost correctly' do
        service = described_class.new(roster: roster)
        total_cost = service.calculate_total_cost

        # 8 + 4 + 8 = 20 hours at $25.50 = $510.00
        expect(total_cost).to eq(510.0)
      end
    end

    context 'when roster has no shifts' do
      it 'returns zero cost' do
        service = described_class.new(roster: roster)
        total_cost = service.calculate_total_cost

        expect(total_cost).to eq(0.0)
      end
    end

    context 'when users have no hourly rate' do
      let(:user_no_rate) { create(:user, hourly_rate: nil) }
      let(:roster_no_rate) { create(:base_roster, user: user_no_rate) }

      before do
        create(:base_shift,
                base_roster: roster_no_rate,
                start_time: '09:00',
                end_time: '17:00')
      end

      it 'skips users without hourly rates' do
        service = described_class.new(roster: roster_no_rate)
        total_cost = service.calculate_total_cost

        expect(total_cost).to eq(0.0)
      end
    end

    context 'with invalid roster' do
      it 'raises an error when roster is nil' do
        expect {
          described_class.new(roster: nil)
        }.to raise_error(ArgumentError, 'Roster is required')
      end
    end
  end
end
