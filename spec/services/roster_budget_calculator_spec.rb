require 'rails_helper'

describe RosterBudgetCalculator do
  let(:user) { create(:user, hourly_rate: 25.0, yearly_sales: 2_000_000, wage_percentage_goal: 14) }
  let(:base_roster) do
    create(:base_roster, user:, starts_at: Date.current, ends_at: Date.current + 6.days)
  end

  describe '#calculate_baseline_sales' do
    it 'calculates weekly sales from yearly average and goal percentage' do
      calculator = RosterBudgetCalculator.new(base_roster)
      # yearly_sales / 52 = 2,000,000 / 52 = 38,461.54
      expected = (2_000_000 / 52.0).round(2)

      expect(calculator.calculate_baseline_sales).to eq(expected)
    end

    it 'returns 0 if user has no yearly_sales' do
      user.update(yearly_sales: nil)
      calculator = RosterBudgetCalculator.new(base_roster)
      expect(calculator.calculate_baseline_sales).to eq(0)
    end
  end

  describe '#calculate_baseline_wages' do
    it 'calculates weekly wages from baseline sales and goal percentage' do
      calculator = RosterBudgetCalculator.new(base_roster)
      baseline_sales = (2_000_000 / 52.0).round(2)
      expected = (baseline_sales * (14 / 100.0)).round(2)

      expect(calculator.calculate_baseline_wages).to eq(expected)
    end

    it 'returns 0 if user has no wage_percentage_goal' do
      user.update(wage_percentage_goal: nil)
      calculator = RosterBudgetCalculator.new(base_roster)
      expect(calculator.calculate_baseline_wages).to eq(0)
    end
  end

  describe '#calculate_actual_wages' do
    it 'sums wages from base shifts using user hourly rate' do
      # Create shifts totaling 10 hours at $25/hr = $250
      create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00') # 5 hrs
      create(:base_shift, base_roster:, day_of_week: 1, start_time: '10:00', end_time: '15:00') # 5 hrs

      calculator = RosterBudgetCalculator.new(base_roster)
      expect(calculator.calculate_actual_wages).to eq(250.0)
    end

    it 'returns 0 if no shifts assigned' do
      calculator = RosterBudgetCalculator.new(base_roster)
      expect(calculator.calculate_actual_wages).to eq(0)
    end
  end

  describe '#calculate_wages_percentage' do
    context 'with sales and wages' do
      it 'calculates percentage as (wages / sales) * 100' do
        base_roster.update(weekly_sales_forecast: 50_000, is_sales_customized: true)
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00') # 5 hrs * $25 = $125

        calculator = RosterBudgetCalculator.new(base_roster)
        expected = (125.0 / 50_000 * 100).round(2)

        expect(calculator.calculate_wages_percentage).to eq(expected)
      end
    end

    context 'with no sales' do
      it 'returns nil' do
        base_roster.update(weekly_sales_forecast: nil, is_sales_customized: false)
        calculator = RosterBudgetCalculator.new(base_roster)
        expect(calculator.calculate_wages_percentage).to be_nil
      end
    end

    context 'with zero wages' do
      it 'returns nil' do
        base_roster.update(weekly_sales_forecast: 50_000, is_sales_customized: true)
        calculator = RosterBudgetCalculator.new(base_roster)
        expect(calculator.calculate_wages_percentage).to be_nil
      end
    end
  end

  describe '#sales_and_wages_display' do
    context 'baseline (not customized)' do
      it 'returns hash with baseline values and status :baseline' do
        # Create a shift to have wages
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00') # 5 hrs * $25 = $125

        calculator = RosterBudgetCalculator.new(base_roster)
        result = calculator.sales_and_wages_display

        expect(result).to include(
          status: :baseline,
          sales: (2_000_000 / 52.0).round(2)
        )
        expect(result[:wages]).to eq(125.0)
        expect(result[:percentage]).to be_a(Numeric)
        expect(result[:percentage]).to be > 0
      end
    end

    context 'customized (user modified)' do
      it 'returns hash with custom values and status :customized' do
        base_roster.update(weekly_sales_forecast: 45_000, is_sales_customized: true, is_wages_customized: true)
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00')

        calculator = RosterBudgetCalculator.new(base_roster)
        result = calculator.sales_and_wages_display

        expect(result[:status]).to eq(:customized)
        expect(result[:sales]).to eq(45_000)
      end
    end
  end
end
