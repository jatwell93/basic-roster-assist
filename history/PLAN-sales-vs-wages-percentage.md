## Plan: Display Sales vs Wages % on Roster UI

**Task**: Add a display showing the percentage of sales vs wages costs on the roster interface. This should integrate with RosterCostCalculator service and display the ratio prominently.

**Analysis**:
- Current: `app/views/rosters/calendar.html.erb` shows weekly summary with Total Shifts, Total Hours, Staff Required
- Affected: `app/controllers/rosters_controller.rb` (calendar action), `app/views/rosters/calendar.html.erb`
- Pattern: Follows existing weekly summary pattern with metric cards using Tailwind CSS styling

**Reuse Strategy**:
- Extend existing `calendar` action in RostersController to load sales forecasts for current week
- Use existing `RosterCostCalculator` service to calculate wages costs
- Add new metric card following existing UI pattern in calendar view
- No new models/services needed - reuse existing SalesForecast and RosterCostCalculator

**Implementation Steps**:
1. Update `calendar` action in RostersController to load sales forecasts for current week
2. Calculate total wages cost using RosterCostCalculator on weekly rosters
3. Calculate sales vs wages percentage: (wages / sales) * 100
4. Add new metric card to calendar view showing the percentage
5. Handle edge cases: no sales data, no roster data, division by zero

**Integration Points**:
- SalesForecast model: Query by date range and user
- RosterCostCalculator service: Calculate costs for weekly rosters
- Calendar view: Add new metric card following existing pattern
- No breaking API changes

**Business Logic**:
- Sales = sum of projected_sales (or actual_sales if available) from sales_forecasts for current week
- Wages = RosterCostCalculator.calculate_total_cost for all weekly rosters in current week
- Percentage = (wages / sales) * 100, displayed as "X% of sales"
- Use actual_sales if available, otherwise projected_sales
- Handle cases where sales = 0 (show "N/A" or special message)

**Tests**: Unit (controller logic for sales/wages calculation) | Integration (calendar view displays percentage) | Manual (UI verification)

**Estimated Work**: 2-3 hours