class AddFinalizationToWeeklyRosters < ActiveRecord::Migration[8.1]
  def change
    add_column :weekly_rosters, :finalized_at, :datetime, null: true
    add_reference :weekly_rosters, :finalized_by, foreign_key: { to_table: :users }, null: true
    add_column :weekly_rosters, :status, :integer, default: 0
  end
end
