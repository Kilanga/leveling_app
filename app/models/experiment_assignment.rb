class ExperimentAssignment < ApplicationRecord
  belongs_to :user

  validates :experiment_key, :variant, presence: true
  validates :experiment_key, uniqueness: { scope: :user_id }
end
