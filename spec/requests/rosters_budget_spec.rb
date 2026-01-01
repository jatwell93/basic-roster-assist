require 'rails_helper'

describe 'Rosters show page with budget display', type: :request do
  let(:user) { create(:user, hourly_rate: 25.0, yearly_sales: 2_000_000, wage_percentage_goal: 14) }
  let(:base_roster) do
    create(:base_roster, user:, starts_at: Date.current, ends_at: Date.current + 6.days)
  end

  describe 'budget display integration' do
    context 'with baseline (not customized)' do
      it 'populates @budget_display data in controller' do
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '17:00')

        # Manually call the RosterBudgetCalculator to test data structure
        budget_calculator = RosterBudgetCalculator.new(base_roster)
        budget_display = budget_calculator.sales_and_wages_display

        expect(budget_display).to include(
          status: :baseline,
          is_customized: false
        )
        expect(budget_display[:sales]).to be_a(Numeric)
        expect(budget_display[:wages]).to be_a(Numeric)
        expect(budget_display[:percentage]).to be_a(Numeric)
      end
    end

    context 'helper methods' do
      it 'formats currency correctly' do
        # Test with ActionView::Helpers included
        view = Object.new
        view.extend(ActionView::Helpers::NumberHelper)
        view.extend(RostersHelper)

        expect(view.format_currency(123.45)).to eq('$123.45')
        expect(view.format_currency(nil)).to eq('--')
      end

      it 'formats percentage correctly' do
        helper = Object.new
        helper.extend(RostersHelper)

        expect(helper.format_percentage(14.5)).to eq('14.5%')
        expect(helper.format_percentage(nil)).to eq('--%')
      end

      it 'returns correct status label' do
        helper = Object.new
        helper.extend(RostersHelper)

        expect(helper.budget_status_label(false)).to eq('Baseline')
        expect(helper.budget_status_label(true)).to eq('Customized')
      end

      it 'returns correct color classes for baseline' do
        helper = Object.new
        helper.extend(RostersHelper)

        expect(helper.budget_status_color(false)).to include('bg-blue-50')
        expect(helper.budget_status_text_color(false)).to include('text-blue-900')
        expect(helper.budget_status_badge_color(false)).to include('bg-blue-100')
      end

      it 'returns correct color classes for customized' do
        helper = Object.new
        helper.extend(RostersHelper)

        expect(helper.budget_status_color(true)).to include('bg-green-50')
        expect(helper.budget_status_text_color(true)).to include('text-green-900')
        expect(helper.budget_status_badge_color(true)).to include('bg-green-100')
      end
    end

    context 'RosterBudgetCalculator integration' do
      it 'calculates baseline correctly' do
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00')

        calculator = RosterBudgetCalculator.new(base_roster)
        display = calculator.sales_and_wages_display

        # 2,000,000 / 52 = 38,461.54
        expect(display[:sales]).to eq((2_000_000 / 52.0).round(2))
        # 5 hrs * $25 = $125
        expect(display[:wages]).to eq(125.0)
        # (125 / 38461.54) * 100 ≈ 0.33%
        expect(display[:percentage]).to be > 0
        expect(display[:status]).to eq(:baseline)
      end

      it 'calculates customized correctly' do
        base_roster.update(weekly_sales_forecast: 50_000, is_sales_customized: true)
        create(:base_shift, base_roster:, day_of_week: 0, start_time: '09:00', end_time: '14:00')

        calculator = RosterBudgetCalculator.new(base_roster)
        display = calculator.sales_and_wages_display

        expect(display[:sales]).to eq(50_000)
        expect(display[:status]).to eq(:customized)
        expect(display[:is_customized]).to be true
      end

      it 'handles zero wages' do
        calculator = RosterBudgetCalculator.new(base_roster)
        display = calculator.sales_and_wages_display

        expect(display[:wages]).to eq(0)
        expect(display[:percentage]).to be_nil
      end
    end
  end
end
