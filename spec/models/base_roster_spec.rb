require 'rails_helper'

RSpec.describe BaseRoster, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:week_type) }
    it { should belong_to(:user) }
    it { should have_many(:base_shifts).dependent(:destroy) }
  end

  describe 'enum validation' do
    it { should define_enum_for(:week_type).with_values(weekly: 0, fortnightly: 1) }
  end

  describe 'date validation' do
    let(:user) { create(:user) }
    let(:valid_roster) { build(:base_roster, user: user, starts_at: Date.today, ends_at: Date.today + 7.days) }
    let(:invalid_roster) { build(:base_roster, user: user, starts_at: Date.today + 7.days, ends_at: Date.today) }

    it 'is valid when end date is after start date' do
      expect(valid_roster).to be_valid
    end

    it 'is invalid when end date is before start date' do
      expect(invalid_roster).to be_invalid
      expect(invalid_roster.errors[:ends_at]).to include('must be after start date')
    end
  end
end
