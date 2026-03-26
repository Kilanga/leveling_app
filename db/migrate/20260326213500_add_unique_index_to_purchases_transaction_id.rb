class AddUniqueIndexToPurchasesTransactionId < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DELETE FROM purchases
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY id) AS row_num
          FROM purchases
          WHERE transaction_id IS NOT NULL
        ) ranked
        WHERE ranked.row_num > 1
      )
    SQL

    add_index :purchases,
              :transaction_id,
              unique: true,
              where: "transaction_id IS NOT NULL",
              name: "index_purchases_on_transaction_id_unique"
  end

  def down
    remove_index :purchases, name: "index_purchases_on_transaction_id_unique"
  end
end
