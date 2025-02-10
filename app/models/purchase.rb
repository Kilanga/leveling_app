class Purchase < ApplicationRecord
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validates :item_type, inclusion: { in: %w[coins boost] }
end
