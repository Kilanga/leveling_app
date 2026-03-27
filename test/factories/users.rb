FactoryBot.define do
  factory :user do
    sequence(:pseudo) { |n| "hunter#{n}" }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    avatar { "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp" }
    confirmed_at { Time.current } # ✅ Permet d'éviter le blocage Devise
    admin { false } # Par défaut, un utilisateur normal

    trait :admin do
      admin { true } # ✅ Permet de créer un admin
    end
  end
end
