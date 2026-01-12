class AddConfigToBaseRosters < ActiveRecord::Migration[8.1]
  def change
    add_column :base_rosters, :opening_time, :time
    add_column :base_rosters, :closing_time, :time
    add_column :base_rosters, :interval_minutes, :integer, default: 30
    add_column :base_rosters, :daily_budget_allocations, :jsonb, default: {}
    add_column :base_rosters, :estimated_hourly_rate, :decimal, precision: 8, scale: 2
  end
end
