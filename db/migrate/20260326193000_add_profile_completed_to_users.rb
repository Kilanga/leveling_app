class AddProfileCompletedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_completed, :boolean, default: true, null: false
  end
end
