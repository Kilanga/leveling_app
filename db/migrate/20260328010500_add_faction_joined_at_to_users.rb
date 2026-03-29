class AddFactionJoinedAtToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :faction_joined_at, :datetime

    now = Time.current
    execute <<~SQL.squish
      UPDATE users
      SET faction_joined_at = '#{now.to_fs(:db)}'
      WHERE faction_id IS NOT NULL AND faction_joined_at IS NULL
    SQL
  end

  def down
    remove_column :users, :faction_joined_at
  end
end
