require "rails_helper"

RSpec.describe FactionInfluence, type: :model do
  describe ".current_cycle_anchor_date" do
    it "uses previous week anchor before wednesday noon" do
      reference = Time.zone.parse("2026-04-01 11:59:00") # Wednesday

      anchor = described_class.current_cycle_anchor_date(reference_time: reference)

      expect(anchor).to eq(Date.parse("2026-03-25"))
    end

    it "switches anchor at wednesday noon" do
      reference = Time.zone.parse("2026-04-01 12:00:00") # Wednesday

      anchor = described_class.current_cycle_anchor_date(reference_time: reference)

      expect(anchor).to eq(Date.parse("2026-04-01"))
    end
  end
end
