class AddPseudoAndAvatarToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pseudo, :string
    add_column :users, :avatar, :string

    # Ajout d'un index unique sur la colonne pseudo
    add_index :users, :pseudo, unique: true
  end
end
