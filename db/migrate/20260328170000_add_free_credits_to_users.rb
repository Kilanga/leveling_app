class AddFreeCreditsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :free_credits, :integer, null: false, default: 0
  end
end
