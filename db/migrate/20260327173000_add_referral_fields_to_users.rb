class AddReferralFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :referred_by, foreign_key: { to_table: :users }, index: true
    add_column :users, :referral_rewarded_at, :datetime
  end
end
