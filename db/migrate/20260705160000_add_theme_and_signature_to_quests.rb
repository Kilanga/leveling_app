# V3 — Phase 2 : les quêtes portent un axe narratif (`theme`) et un drapeau
# `signature` pour les quêtes « boss » d'aspiration, tenues hors du tirage
# quotidien du Système.
class AddThemeAndSignatureToQuests < ActiveRecord::Migration[8.1]
  def change
    add_column :quests, :theme, :string
    add_column :quests, :signature, :boolean, null: false, default: false
    add_index :quests, :signature
  end
end
