# Réécriture du catalogue V2 (ton Solo Leveling, difficulté E→S, XP
# rééquilibré). Les quêtes existantes sont retrouvées par leur ancien titre
# et mises à jour en place : les user_quests des joueurs sont préservées.
class RewriteQuestCatalog < ActiveRecord::Migration[8.1]
  def up
    return unless Category.table_exists?

    say_with_time "Réécriture du catalogue de quêtes (QuestCatalog.sync!)" do
      QuestCatalog.sync!
    end
  end

  def down
    # Volontairement irréversible : l'ancien catalogue n'est pas restauré.
  end
end
