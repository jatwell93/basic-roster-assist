class CreateSalesForecasts < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_forecasts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :forecast_type
      t.date :start_date
      t.date :end_date
      t.decimal :projected_sales, precision: 8, scale: 2
      t.decimal :actual_sales, precision: 8, scale: 2
      t.integer :confidence_level

      t.timestamps
    end
  end
end
