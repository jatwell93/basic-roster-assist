class AddTargetWagePercentageToBaseRosters < ActiveRecord::Migration[8.1]
  def change
    add_column :base_rosters, :target_wage_percentage, :decimal, precision: 5, scale: 2
  end
end
