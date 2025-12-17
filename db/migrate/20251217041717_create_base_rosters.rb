class CreateBaseRosters < ActiveRecord::Migration[8.1]
  def change
    create_table :base_rosters do |t|
      t.string :name, null: false
      t.date :starts_at, null: false
      t.date :ends_at, null: false
      t.integer :week_type, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
