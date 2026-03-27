class AddDailyLoginFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :daily_login_streak_count, :integer, default: 0, null: false
    add_column :users, :daily_login_last_claimed_on, :date
  end
end
