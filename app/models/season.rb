# Une saison de 6 semaines. L'XP saisonnier vit dans user_seasons ;
# XP, rangs et succès des joueurs restent permanents (rien n'est reset).
class Season < ApplicationRecord
  has_many :user_seasons, dependent: :destroy
  has_many :users, through: :user_seasons

  validates :number, presence: true, uniqueness: true, numericality: { greater_than: 0 }
  validates :name, :starts_on, :ends_on, presence: true
  validate :ends_after_start

  scope :covering, ->(date) { where("starts_on <= ? AND ends_on >= ?", date, date) }
  scope :finished_unclosed, ->(date = Time.zone.today) { where(closed_at: nil).where("ends_on < ?", date) }

  def active?(date = Time.zone.today)
    date.between?(starts_on, ends_on)
  end

  def closed?
    closed_at.present?
  end

  def days_remaining(date = Time.zone.today)
    [ (ends_on - date).to_i, 0 ].max
  end

  private

  def ends_after_start
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, :invalid) if ends_on <= starts_on
  end
end
