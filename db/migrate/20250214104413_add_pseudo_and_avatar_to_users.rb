class AddPseudoAndAvatarToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pseudo, :string, unique: true
    add_column :users, :avatar, :string

    add_index :users, :pseudo, unique: true # Ajoute une contrainte d'unicité
  end
end
