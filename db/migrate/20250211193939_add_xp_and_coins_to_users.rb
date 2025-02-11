class AddXpAndCoinsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :xp, :integer, default: 0
    add_column :users, :coins, :integer, default: 0
  end
end
