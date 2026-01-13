class MakeAwardRateUserIdNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :award_rates, :user_id, true
  end
end
