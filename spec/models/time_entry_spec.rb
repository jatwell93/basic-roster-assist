require 'rails_helper'

RSpec.describe TimeEntry, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:clock_in) }
    it { should belong_to(:user) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'time validation' do
    let(:user) { create(:user) }
    let(:valid_entry) { build(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: Time.current) }
    let(:invalid_entry) { build(:time_entry, user: user, clock_in: Time.current, clock_out: 1.hour.ago) }

    it 'is valid when clock_out is after clock_in' do
      expect(valid_entry).to be_valid
    end

    it 'is invalid when clock_out is before clock_in' do
      expect(invalid_entry).to be_invalid
      expect(invalid_entry.errors[:clock_out]).to include('must be after clock in')
    end

    it 'is valid when clock_out is nil (ongoing entry)' do
      entry = build(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil)
      expect(entry).to be_valid
    end
  end

  describe 'business logic' do
    let(:user) { create(:user) }

    describe '#duration' do
      it 'calculates duration when both times are present' do
        clock_in = 2.hours.ago
        clock_out = 1.hour.ago
        entry = create(:time_entry, user: user, clock_in: clock_in, clock_out: clock_out)

        expect(entry.duration).to eq(1.hour)
      end

      it 'returns nil when clock_out is nil' do
        entry = create(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil)
        expect(entry.duration).to be_nil
      end
    end

    describe '#ongoing?' do
      it 'returns true when clock_out is nil' do
        entry = create(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil)
        expect(entry.ongoing?).to be true
      end

      it 'returns false when clock_out is present' do
        entry = create(:time_entry, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
        expect(entry.ongoing?).to be false
      end
    end

    describe '#completed?' do
      it 'returns true when clock_out is present' do
        entry = create(:time_entry, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
        expect(entry.completed?).to be true
      end

      it 'returns false when clock_out is nil' do
        entry = create(:time_entry, user: user, clock_in: 1.hour.ago, clock_out: nil)
        expect(entry.completed?).to be false
      end
    end
  end
end
