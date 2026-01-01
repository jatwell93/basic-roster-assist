class AddSalesBudgetToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :yearly_sales, :decimal, precision: 12, scale: 2
    add_column :users, :wage_percentage_goal, :integer, default: 14
  end
end
