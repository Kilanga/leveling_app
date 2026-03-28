class Faction < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :faction_influences, dependent: :destroy

  validates :name, :slug, :color_hex, presence: true
  validates :slug, uniqueness: true

  DEFAULTS = [
    { name: "Aegis", slug: "aegis", color_hex: "#2f7df6" },
    { name: "Ember", slug: "ember", color_hex: "#ef5b2a" },
    { name: "Verdant", slug: "verdant", color_hex: "#2ca66f" }
  ].freeze

  def self.bootstrap_defaults!
    DEFAULTS.each do |attrs|
      find_or_create_by!(slug: attrs[:slug]) do |faction|
        faction.name = attrs[:name]
        faction.color_hex = attrs[:color_hex]
      end
    end
  end
end
