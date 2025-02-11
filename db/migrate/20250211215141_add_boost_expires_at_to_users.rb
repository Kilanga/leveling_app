class AddBoostExpiresAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :boost_expires_at, :datetime
  end
end
