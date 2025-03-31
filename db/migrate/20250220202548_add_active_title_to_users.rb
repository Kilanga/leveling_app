class AddActiveTitleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active_title_id, :integer
  end
end
