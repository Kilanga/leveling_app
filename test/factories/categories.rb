FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Aventure#{n}" }
  end
end
