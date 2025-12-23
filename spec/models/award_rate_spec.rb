require 'rails_helper'

RSpec.describe AwardRate, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:award_code) }
    it { should validate_length_of(:award_code).is_at_least(2) }
    it { should validate_presence_of(:classification) }
    it { should validate_presence_of(:rate) }
    it { should validate_numericality_of(:rate).is_greater_than(0) }
    it { should validate_numericality_of(:rate).has_precision_and_scale(8, 2) }
    it { should validate_presence_of(:effective_date) }
    it { should validate_presence_of(:user) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    before do
      create(:award_rate, user: user, award_code: 'HOSPITALITY', effective_date: 1.month.ago)
      create(:award_rate, user: user, award_code: 'RETAIL', effective_date: Date.current)
      create(:award_rate, user: user, award_code: 'HOSPITALITY', effective_date: 1.month.from_now)
    end

    describe '.active' do
      it 'returns only active award rates' do
        active_rates = AwardRate.active
        expect(active_rates.count).to eq(2)
        expect(active_rates.map(&:award_code)).to include('HOSPITALITY', 'RETAIL')
      end
    end

    describe '.by_award_code' do
      it 'filters by award code' do
        hospitality_rates = AwardRate.by_award_code('HOSPITALITY')
        expect(hospitality_rates.count).to eq(2)
        expect(hospitality_rates.all? { |rate| rate.award_code == 'HOSPITALITY' }).to be true
      end
    end

    describe '.for_user' do
      it 'filters by user' do
        user_rates = AwardRate.for_user(user)
        expect(user_rates.count).to eq(3)
        expect(user_rates.all? { |rate| rate.user == user }).to be true
      end
    end

    describe '.current' do
      it 'returns current month rates' do
        current_rates = AwardRate.current
        expect(current_rates.count).to eq(2)
      end
    end
  end

  describe 'class methods' do
    let(:user) { create(:user) }
    let(:award_code) { 'HOSPITALITY' }
    let(:classification) { 'Level 1' }

    describe '.fetch_and_update_rates_for_user' do
      context 'when API call succeeds' do
        before do
          allow_any_instance_of(FairWorkApiService).to receive(:fetch_award_rate)
            .with(award_code)
            .and_return(OpenStruct.new(success?: true, rate: 28.50, error: nil))
        end

        it 'creates or updates award rate with API data' do
          result = AwardRate.fetch_and_update_rates_for_user(user, award_code, classification)

          expect(result).to be_persisted
          expect(result.award_code).to eq(award_code)
          expect(result.classification).to eq(classification)
          expect(result.rate).to eq(28.50)
          expect(result.effective_date).to eq(Date.current)
        end

        it 'updates existing award rate' do
          existing_rate = create(:award_rate, user: user, award_code: award_code, classification: classification, rate: 25.00)

          result = AwardRate.fetch_and_update_rates_for_user(user, award_code, classification)

          expect(result.id).to eq(existing_rate.id)
          expect(result.rate).to eq(28.50)
        end
      end

      context 'when API call fails' do
        before do
          allow_any_instance_of(FairWorkApiService).to receive(:fetch_award_rate)
            .with(award_code)
            .and_return(OpenStruct.new(success?: false, rate: nil, error: 'API Error'))
        end

        it 'returns nil and logs error' do
          expect(Rails.logger).to receive(:error).with(/Failed to fetch award rate for #{award_code}/)

          result = AwardRate.fetch_and_update_rates_for_user(user, award_code, classification)
          expect(result).to be_nil
        end
      end
    end

    describe '.update_all_rates_from_api' do
      let(:user_with_awards) { create(:user) }
      let(:user_without_awards) { create(:user) }

      before do
        create(:award_rate, user: user_with_awards, award_code: 'HOSPITALITY')
        create(:award_rate, user: user_with_awards, award_code: 'RETAIL')

        allow_any_instance_of(FairWorkApiService).to receive(:fetch_award_rate)
          .and_return(OpenStruct.new(success?: true, rate: 28.50, error: nil))
      end

      it 'updates rates for all users with award assignments' do
        expect {
          AwardRate.update_all_rates_from_api
        }.to change { AwardRate.count }.by(0) # No new records, just updates

        user_with_awards.award_rates.each do |rate|
          expect(rate.reload.rate).to eq(28.50)
        end
      end
    end
  end
end
