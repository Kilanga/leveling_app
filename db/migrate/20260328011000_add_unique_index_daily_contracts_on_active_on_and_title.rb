class AddUniqueIndexDailyContractsOnActiveOnAndTitle < ActiveRecord::Migration[8.0]
  def change
    add_index :daily_contracts, [ :active_on, :title ], unique: true, name: "index_daily_contracts_on_active_on_and_title"
  end
end
