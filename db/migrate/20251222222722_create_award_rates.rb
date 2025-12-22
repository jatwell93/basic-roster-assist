class CreateAwardRates < ActiveRecord::Migration[8.1]
  def change
    create_table :award_rates do |t|
      t.string :award_code
      t.string :classification
      t.decimal :rate
      t.references :user, null: false, foreign_key: true
      t.date :effective_date

      t.timestamps
    end
  end
end
