class AddPinToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :encrypted_pin, :string
    add_column :users, :encrypted_pin_iv, :string
  end
end
