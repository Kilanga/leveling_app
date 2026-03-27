class Purchase < ApplicationRecord
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validates :item_type, presence: true
  validates :status, presence: true
  validates :transaction_id, uniqueness: true, allow_nil: true
end
