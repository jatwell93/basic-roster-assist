require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'enums' do
    it { should define_enum_for(:role).with_values(admin: 0, manager: 1, staff: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'default values' do
    it 'defaults to staff role' do
      user = User.new
      expect(user.role).to eq('staff')
    end
  end
end
