require "rails_helper"

RSpec.describe WeeklyQuest, type: :model do
  it "is valid with a title and category" do
    category = Category.create!(name: "Weekly Quest Category")
    weekly_quest = described_class.new(
      title: "Weekly Test Quest",
      description: "Description test",
      xp_reward: 300,
      category: category,
      valid_until: 7.days.from_now
    )

    expect(weekly_quest).to be_valid
  end
end
