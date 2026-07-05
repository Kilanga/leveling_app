require "rails_helper"

RSpec.describe QuestCatalog do
  describe ".sync!" do
    it "crée les catégories et les quêtes standard avec le barème XP V3" do
      described_class.sync!

      QuestCatalog::ENTRIES.each do |category_name, entries|
        expect(Category.exists?(name: category_name)).to be(true)

        entries.each do |entry|
          quest = Quest.find_by(title: entry[:title])
          expect(quest).to be_present
          expect(quest.xp).to eq(QuestCatalog::XP_BY_DIFFICULTY.fetch(entry[:difficulty]))
          expect(quest.signature).to be(false)
          expect(quest.theme).to be_present
        end
      end
    end

    it "renseigne le thème par défaut de la catégorie" do
      described_class.sync!

      QuestCatalog::CATEGORY_THEME.each do |category_name, theme|
        category = Category.find_by(name: category_name)
        quests = Quest.where(category: category, signature: false)
        # Les quêtes sans thème explicite héritent du thème de leur catégorie.
        expect(quests.where(theme: theme)).to be_present
      end
    end

    it "crée les quêtes signature « boss » avec un XP doublé et hors standard" do
      described_class.sync!

      QuestCatalog::SIGNATURE_ENTRIES.each do |_category_name, entries|
        entries.each do |entry|
          quest = Quest.find_by(title: entry[:title])
          expect(quest).to be_present
          expect(quest.signature).to be(true)
          expected = QuestCatalog::XP_BY_DIFFICULTY.fetch(entry[:difficulty]) * QuestCatalog::SIGNATURE_XP_MULTIPLIER
          expect(quest.xp).to eq(expected)
        end
      end

      expect(Quest.signature.count).to eq(QuestCatalog::SIGNATURE_ENTRIES.values.flatten.size)
      expect(Quest.standard).not_to include(Quest.signature.first)
    end

    it "est idempotent : relancer ne duplique pas les quêtes" do
      described_class.sync!
      count_after_first = Quest.count

      described_class.sync!
      expect(Quest.count).to eq(count_after_first)
    end

    it "met à jour une quête existante retrouvée par son ancien titre (legacy)" do
      category = Category.find_or_create_by!(name: "Discipline")
      entry = QuestCatalog::ENTRIES["Discipline"].find { |e| e[:legacy_title].present? }
      legacy = Quest.create!(
        title: entry[:legacy_title],
        description: "ancienne description",
        xp: 10,
        difficulty: "E",
        category: category
      )

      described_class.sync!

      legacy.reload
      expect(legacy.title).to eq(entry[:title])
      expect(legacy.xp).to eq(QuestCatalog::XP_BY_DIFFICULTY.fetch(entry[:difficulty]))
      expect(Quest.where(title: entry[:title]).count).to eq(1)
    end
  end
end
