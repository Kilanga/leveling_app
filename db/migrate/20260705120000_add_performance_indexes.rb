class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # XP hebdo par joueur (classement, notifier, profil)
    add_index :user_quests, [ :user_id, :completed, :updated_at ], name: "index_user_quests_on_user_completed_updated"
    # Scans globaux (classement groupé, joueurs inactifs)
    add_index :user_quests, [ :completed, :updated_at ], name: "index_user_quests_on_completed_updated"
    # Déduplication des notifications par type et semaine
    add_index :in_app_notifications, [ :user_id, :kind, :created_at ], name: "index_notifications_on_user_kind_created"
  end
end
