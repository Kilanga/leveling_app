class UserItem < ApplicationRecord
  belongs_to :user
  belongs_to :shop_item

  validates :user_id, uniqueness: { scope: :shop_item_id, message: "a déjà cet objet" }
end
