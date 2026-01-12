require 'rails_helper'

RSpec.describe BaseShift, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:day_of_week) }
    it { should validate_presence_of(:shift_type) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should belong_to(:base_roster) }
  end

  describe 'enum validation' do
    it { should define_enum_for(:day_of_week).with_values(sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6) }
    it { should define_enum_for(:shift_type).with_values(morning: 0, afternoon: 1, evening: 2, night: 3) }
  end

  describe 'time validation' do
    let(:base_roster) { create(:base_roster) }
    let(:valid_shift) { build(:base_shift, base_roster: base_roster, start_time: '08:00', end_time: '16:00') }
    let(:overnight_shift) { build(:base_shift, base_roster: base_roster, start_time: '18:00', end_time: '02:00') }
    let(:invalid_duration) { build(:base_shift, base_roster: base_roster, start_time: '09:00', end_time: '09:00') }

    it 'is valid when end time is after start time' do
      expect(valid_shift).to be_valid
    end

    it 'is valid when invalid overnight shift (user intentionally allows it)' do
       # The system now allows overnight shifts
       expect(overnight_shift).to be_valid
    end

    it 'is invalid when duration is not reasonable (e.g. 24 hours)' do
      expect(invalid_duration).to be_invalid
      expect(invalid_duration.errors[:end_time]).to include('must result in a shift between 1 and 23 hours')
    end
  end

  describe 'overlapping validation' do
    let(:base_roster) { create(:base_roster) }
    let!(:existing_shift) { create(:base_shift, base_roster: base_roster, day_of_week: :monday, start_time: '08:00', end_time: '12:00') }
    let(:overlapping_shift) { build(:base_shift, base_roster: base_roster, day_of_week: :monday, start_time: '10:00', end_time: '14:00') }
    let(:non_overlapping_shift) { build(:base_shift, base_roster: base_roster, day_of_week: :monday, start_time: '14:00', end_time: '18:00') }

    it 'allows overlapping shifts in base templates' do
      expect(overlapping_shift).to be_valid
    end

    it 'is valid when shift does not overlap with existing shift' do
      expect(non_overlapping_shift).to be_valid
    end
  end
end
