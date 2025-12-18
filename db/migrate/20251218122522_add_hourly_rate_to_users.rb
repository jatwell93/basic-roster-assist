class AddHourlyRateToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :hourly_rate, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
