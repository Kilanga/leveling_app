FactoryBot.define do
  factory :user_quest do
    association :user
    association :quest
    completed { false }
  end
end
