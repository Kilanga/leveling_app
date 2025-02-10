class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.string :item_type
      t.string :status
      t.string :transaction_id

      t.timestamps
    end
  end
end
