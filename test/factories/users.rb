FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.current } # ✅ Permet d'éviter le blocage Devise
    admin { false } # Par défaut, un utilisateur normal

    trait :admin do
      admin { true } # ✅ Permet de créer un admin
    end
  end
end
