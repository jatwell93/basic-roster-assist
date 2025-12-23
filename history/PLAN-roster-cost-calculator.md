## Plan: Implement RosterCostCalculator service

**Analysis**:
- Current: `app/services/wage_report_generator.rb` (calculates actual wages from TimeEntry records)
- Affected: New `app/services/roster_cost_calculator.rb`, `spec/services/roster_cost_calculator_spec.rb`
- Pattern: Follows existing WageReportGenerator service pattern (initialize with params, call method for result)

**Reuse Strategy**:
- Extend service pattern from WageReportGenerator but for projected costs
- Use BaseRoster and BaseShift models for roster data
- Leverage User.hourly_rate for wage calculations
- Follow existing service initialization and method naming conventions

**Implementation Steps**:
1. Create RosterCostCalculator service class (line 1-50)
2. Implement initialize method accepting roster parameter (line 5-10)
3. Add calculate_total_cost method to sum all shift costs (line 15-35)
4. Add calculate_shift_cost private method for individual shift calculations (line 40-50)
5. Write comprehensive tests following WageReportGenerator test patterns (line 1-80)

**Integration Points**:
- Roster UI will call RosterCostCalculator.new(roster).calculate_total_cost
- No breaking changes to existing services
- Follows Rails service pattern established in WageReportGenerator

**Tests**: Unit tests for cost calculations, edge cases (missing rates, zero duration), integration with roster models

**Estimated Work**: 1-2 hours