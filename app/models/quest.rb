class Quest < ApplicationRecord
  # Difficultés alignées sur les rangs de chasseur (cf. HunterRank).
  DIFFICULTIES = %w[E D C B A S].freeze

  belongs_to :category
  has_many :user_quests, dependent: :destroy
  has_many :users, through: :user_quests
  has_many :system_quest_assignments, dependent: :destroy

  validates :title, :description, :xp, :category, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_nil: true

  scope :with_difficulty, ->(letters) { where(difficulty: Array(letters)) }

  # Quêtes signature « boss » (V3) : objectifs d'aspiration à fort XP, tenus
  # hors du tirage quotidien du Système. `standard` = tout le reste.
  scope :signature, -> { where(signature: true) }
  scope :standard, -> {
    if Quest.column_names.include?("signature")
      where(signature: [ false, nil ])
    else
      all
    end
  }

  def signature?
    has_attribute?(:signature) ? !!self[:signature] : false
  end

  def difficulty_index
    DIFFICULTIES.index(difficulty) || 0
  end

  def daily_featured?
    has_attribute?(:daily_featured) ? self[:daily_featured] : false
  end
end
