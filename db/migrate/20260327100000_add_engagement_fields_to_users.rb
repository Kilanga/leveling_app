class AddEngagementFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :onboarding_completed_at, :datetime
    add_column :users, :onboarding_focus, :text, default: "", null: false
    add_column :users, :weekly_streak_count, :integer, default: 0, null: false
    add_column :users, :weekly_streak_last_completed_on, :date
    add_column :users, :weekly_streak_freeze_used_for_week, :date
  end
end
