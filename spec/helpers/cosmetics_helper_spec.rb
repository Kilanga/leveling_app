require "rails_helper"

RSpec.describe CosmeticsHelper, type: :helper do
  Cosmetic = Struct.new(:name)

  describe "#frame_wrapper_classes (V3 Phase 3)" do
    it "mappe les nouveaux cadres" do
      expect(helper.frame_wrapper_classes(Cosmetic.new("Cadre Armée des Ombres"))).to eq("profile-frame-armee")
      expect(helper.frame_wrapper_classes(Cosmetic.new("Cadre de la Faille"))).to eq("profile-frame-faille")
    end

    it "ne casse pas les cadres existants" do
      expect(helper.frame_wrapper_classes(Cosmetic.new("Cadre Monarque des Ombres"))).to eq("profile-frame-monarque")
      expect(helper.frame_wrapper_classes(Cosmetic.new("Cadre Porte de Donjon"))).to eq("profile-frame-donjon")
      expect(helper.frame_wrapper_classes(nil)).to eq("profile-frame-none")
    end
  end

  describe "#xp_theme_classes (V3 Phase 3)" do
    it "mappe les nouveaux thèmes" do
      expect(helper.xp_theme_classes(Cosmetic.new("Theme XP Eveil National"))).to eq("xp-theme-eveil")
      expect(helper.xp_theme_classes(Cosmetic.new("Theme XP Couronne Supreme"))).to eq("xp-theme-couronne")
    end

    it "ne casse pas les thèmes existants" do
      expect(helper.xp_theme_classes(Cosmetic.new("Theme XP Sang de Boss"))).to eq("xp-theme-boss")
      expect(helper.xp_theme_classes(Cosmetic.new("Theme XP Ombre Violette"))).to eq("xp-theme-ombre")
      expect(helper.xp_theme_classes(nil)).to eq("xp-theme-standard")
    end
  end

  describe "#profile_card_classes (V3 Phase 3)" do
    it "mappe les nouvelles cartes" do
      expect(helper.profile_card_classes(Cosmetic.new("Carte de Visite Souverain"))).to eq("profile-card-souverain")
      expect(helper.profile_card_classes(Cosmetic.new("Carte de Visite Monarque"))).to eq("profile-card-monarque")
    end

    it "ne casse pas les cartes existantes" do
      expect(helper.profile_card_classes(Cosmetic.new("Carte de Visite Rang S"))).to eq("profile-card-rang-s")
      expect(helper.profile_card_classes(nil)).to eq("profile-card-none")
    end
  end

  describe "catalogue Phase 3 dans PurchasesController::DEFAULT_COSMETIC_ITEMS" do
    let(:by_name) { PurchasesController::DEFAULT_COSMETIC_ITEMS.index_by { |i| i[:name] } }

    it "ajoute 3 cosmétiques Orbes (price_coins, pas d'euros)" do
      ["Cadre Armee des Ombres", "Theme XP Eveil National", "Carte de Visite Souverain"].each do |name|
        item = by_name.fetch(name)
        expect(item[:price_coins]).to be_present
        expect(item[:price_euros]).to be_nil
      end
    end

    it "ajoute 3 objets premium (price_euros, pas d'Orbes, cosmétique only)" do
      premium_types = []
      ["Cadre de la Faille", "Theme XP Couronne Supreme", "Carte de Visite Monarque"].each do |name|
        item = by_name.fetch(name)
        expect(item[:price_euros]).to be_present
        expect(item[:price_coins]).to be_nil
        premium_types << item[:item_type]
      end
      expect(premium_types).to all(be_in(%w[profile_frame xp_theme profile_card]))
    end
  end
end
