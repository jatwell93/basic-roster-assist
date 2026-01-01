class AddWeeklySalesBudgetToBaseRosters < ActiveRecord::Migration[8.1]
  def change
    add_column :base_rosters, :weekly_sales_forecast, :decimal, precision: 10, scale: 2
    add_column :base_rosters, :is_sales_customized, :boolean, default: false
    add_column :base_rosters, :is_wages_customized, :boolean, default: false
  end
end
