require 'rails_helper'

RSpec.describe SalesForecast, type: :model do
  let(:user) { create(:user) }
  subject { build(:sales_forecast, user: user) }

  describe 'validations' do
    it { should validate_presence_of(:forecast_type) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:projected_sales) }
    it { should validate_presence_of(:confidence_level) }
    it { should belong_to(:user) }
  end

  describe 'enum validation' do
    it { should define_enum_for(:forecast_type).with_values(weekly: 0, fortnightly: 1, monthly: 2) }
  end

  describe 'numericality validation' do
    it { should validate_numericality_of(:projected_sales).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:actual_sales).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:confidence_level).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'date validation' do
    let(:user) { create(:user) }
    let(:valid_forecast) { build(:sales_forecast, user: user, start_date: Date.today, end_date: Date.today + 7.days) }
    let(:invalid_forecast) { build(:sales_forecast, user: user, start_date: Date.today + 7.days, end_date: Date.today) }

    it 'is valid when end date is after start date' do
      expect(valid_forecast).to be_valid
    end

    it 'is invalid when end date is before start date' do
      expect(invalid_forecast).to be_invalid
      expect(invalid_forecast.errors[:end_date]).to include('must be after start date')
    end
  end

  describe 'confidence level validation' do
    let(:user) { create(:user) }
    let(:valid_forecast) { build(:sales_forecast, user: user, confidence_level: 75) }
    let(:invalid_forecast_low) { build(:sales_forecast, user: user, confidence_level: -1) }
    let(:invalid_forecast_high) { build(:sales_forecast, user: user, confidence_level: 101) }

    it 'is valid when confidence level is between 0 and 100' do
      expect(valid_forecast).to be_valid
    end

    it 'is invalid when confidence level is below 0' do
      expect(invalid_forecast_low).to be_invalid
      expect(invalid_forecast_low.errors[:confidence_level]).to include('must be greater than or equal to 0')
    end

    it 'is invalid when confidence level is above 100' do
      expect(invalid_forecast_high).to be_invalid
      expect(invalid_forecast_high.errors[:confidence_level]).to include('must be less than or equal to 100')
    end
  end

  describe 'projected sales validation' do
    let(:user) { create(:user) }
    let(:valid_forecast) { build(:sales_forecast, user: user, projected_sales: 1000.50) }
    let(:invalid_forecast) { build(:sales_forecast, user: user, projected_sales: -100) }

    it 'is valid when projected sales is positive' do
      expect(valid_forecast).to be_valid
    end

    it 'is invalid when projected sales is negative' do
      expect(invalid_forecast).to be_invalid
      expect(invalid_forecast.errors[:projected_sales]).to include('must be greater than or equal to 0')
    end
  end

  describe 'actual sales validation' do
    let(:user) { create(:user) }
    let(:valid_forecast_with_actual) { build(:sales_forecast, user: user, actual_sales: 1200.75) }
    let(:valid_forecast_without_actual) { build(:sales_forecast, user: user, actual_sales: nil) }
    let(:invalid_forecast) { build(:sales_forecast, user: user, actual_sales: -50) }

    it 'is valid when actual sales is positive' do
      expect(valid_forecast_with_actual).to be_valid
    end

    it 'is valid when actual sales is nil' do
      expect(valid_forecast_without_actual).to be_valid
    end

    it 'is invalid when actual sales is negative' do
      expect(invalid_forecast).to be_invalid
      expect(invalid_forecast.errors[:actual_sales]).to include('must be greater than or equal to 0')
    end
  end

  describe 'forecast type validation' do
    let(:user) { create(:user) }
    let(:valid_weekly) { build(:sales_forecast, user: user, forecast_type: :weekly) }
    let(:valid_fortnightly) { build(:sales_forecast, user: user, forecast_type: :fortnightly) }
    let(:valid_monthly) { build(:sales_forecast, user: user, forecast_type: :monthly) }

    it 'is valid for weekly forecast type' do
      expect(valid_weekly).to be_valid
    end

    it 'is valid for fortnightly forecast type' do
      expect(valid_fortnightly).to be_valid
    end

    it 'is valid for monthly forecast type' do
      expect(valid_monthly).to be_valid
    end

    it 'is invalid for unknown forecast type' do
      forecast = build(:sales_forecast, user: user, forecast_type: :weekly)
      forecast.forecast_type = nil
      expect(forecast).to be_invalid
      expect(forecast.errors[:forecast_type]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:weekly_forecast) { create(:sales_forecast, user: user, forecast_type: :weekly) }
    let!(:fortnightly_forecast) { create(:sales_forecast, user: user, forecast_type: :fortnightly) }
    let!(:monthly_forecast) { create(:sales_forecast, user: user, forecast_type: :monthly) }

    it 'returns weekly forecasts' do
      expect(SalesForecast.weekly).to eq([ weekly_forecast ])
    end

    it 'returns fortnightly forecasts' do
      expect(SalesForecast.fortnightly).to eq([ fortnightly_forecast ])
    end

    it 'returns monthly forecasts' do
      expect(SalesForecast.monthly).to eq([ monthly_forecast ])
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:forecast) { create(:sales_forecast, user: user, projected_sales: 1000.00, actual_sales: 1200.00) }

    describe '#variance' do
      it 'returns the difference between actual and projected sales' do
        expect(forecast.variance).to eq(200.00)
      end

      it 'returns 0 when actual sales is nil' do
        forecast.update(actual_sales: nil)
        expect(forecast.variance).to eq(0)
      end
    end

    describe '#variance_percentage' do
      it 'returns the variance as a percentage of projected sales' do
        expect(forecast.variance_percentage).to eq(20.0)
      end

      it 'returns 0 when actual sales is nil' do
        forecast.update(actual_sales: nil)
        expect(forecast.variance_percentage).to eq(0)
      end

      it 'returns 0 when projected sales is 0' do
        forecast.update(projected_sales: 0, actual_sales: 100)
        expect(forecast.variance_percentage).to eq(0)
      end
    end

    describe '#accuracy' do
      it 'returns the accuracy percentage' do
        expect(forecast.accuracy).to eq(120.0)
      end

      it 'returns 0 when actual sales is nil' do
        forecast.update(actual_sales: nil)
        expect(forecast.accuracy).to eq(0)
      end

      it 'returns 0 when projected sales is 0' do
        forecast.update(projected_sales: 0, actual_sales: 100)
        expect(forecast.accuracy).to eq(0)
      end
    end
  end
end
