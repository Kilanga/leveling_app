require "test_helper"

class QuestTest < ActiveSupport::TestCase
  def setup
    @category = Category.create(name: "Force")
  end

  test "est valide avec un titre, une description, un XP et une catégorie" do
    quest = Quest.new(title: "Test Quest", description: "Description", xp: 50, category: @category)
    assert quest.valid?
  end

  test "est invalide sans titre" do
    quest = Quest.new(description: "Description", xp: 50, category: @category)
    assert_not quest.valid?
  end
end
