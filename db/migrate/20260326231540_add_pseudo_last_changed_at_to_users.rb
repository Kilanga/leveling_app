class AddPseudoLastChangedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pseudo_last_changed_at, :datetime
  end
end
