# V3 — Phase 2 : réécrit le catalogue avec le barème XP relevé, renseigne le
# thème de chaque quête et crée les quêtes signature « boss ».
# Les quêtes existantes sont retrouvées par titre (ou legacy_title) et mises à
# jour en place : les user_quests et l'historique des joueurs sont préservés.
class ExtendQuestCatalogV3 < ActiveRecord::Migration[8.1]
  def up
    return unless Category.table_exists? && Quest.table_exists?

    say_with_time "Extension du catalogue de quêtes V3 (QuestCatalog.sync!)" do
      QuestCatalog.sync!
    end
  end

  def down
    # Volontairement irréversible : le barème et les thèmes V3 restent en place.
  end
end
