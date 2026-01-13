require 'rails_helper'

RSpec.describe WeeklyRoster, type: :model do
  let(:user) { create(:user) }
  let(:base_roster) { create(:base_roster, user: user) }
  subject { build(:weekly_roster, user: user, base_roster: base_roster) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:week_start_date) }
    it { should validate_presence_of(:week_end_date) }
    it { should validate_presence_of(:week_type) }
    it { should validate_presence_of(:base_roster_id) }
    it { should validate_presence_of(:user_id) }
    it { should belong_to(:user) }
    it { should belong_to(:base_roster) }
    it { should have_many(:weekly_shifts).dependent(:destroy) }
  end

  describe 'enum validation' do
    it { should define_enum_for(:week_type).with_values(weekly: 0, fortnightly: 1) }
  end

  describe 'date validation' do
    let(:user) { create(:user) }
    let(:base_roster) { create(:base_roster, user: user) }
    let(:valid_roster) { build(:weekly_roster, user: user, base_roster: base_roster, week_start_date: Date.today, week_end_date: Date.today + 7.days) }
    let(:invalid_roster) { build(:weekly_roster, user: user, base_roster: base_roster, week_start_date: Date.today + 7.days, week_end_date: Date.today) }

    it 'is valid when end date is after start date' do
      expect(valid_roster).to be_valid
    end

    it 'is invalid when end date is before start date' do
      expect(invalid_roster).to be_invalid
      expect(invalid_roster.errors[:week_end_date]).to include('must be after start date')
    end
  end
end
