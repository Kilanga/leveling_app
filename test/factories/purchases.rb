FactoryBot.define do
  factory :purchase do
    association :user
    amount { 100 }
    status { "completed" }
  end
end
