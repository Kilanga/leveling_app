FactoryBot.define do
  factory :user_stat do
    xp { 0 }
    level { 1 }
    association :user
  end
end
