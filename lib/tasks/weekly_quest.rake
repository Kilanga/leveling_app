require "openai"

namespace :quests do
  desc "Génère les quêtes hebdomadaires"
  task generate_weekly_quests: :environment do
    WeeklyQuest.where("valid_until < ?", Time.current).destroy_all

    OpenAI.configure do |config|
      config.access_token = Rails.application.credentials.dig(:openai, :api_key)
    end
    client = OpenAI::Client.new



    categories = Category.all
    categories.each do |category|
      prompt = <<~PROMPT
  Imagine un jeu de développement personnel inspiré de Solo Leveling.
  Génère une quête hebdomadaire unique pour un joueur dans la catégorie "#{category.name}".
  La quête doit être motivante, immersive et adaptée à la progression du joueur.
  Évite les formules génériques comme "Accomplis une tâche dans cette catégorie".
  Exemples :
  - Pour Fitness : "Relève le défi des 100 pompes en 7 jours et deviens plus fort."
  - Pour Méditation : "Atteins 30 minutes de pleine conscience chaque jour pour maîtriser ton esprit."
  - Pour Coding : "Crée une mini-application en Ruby en une semaine."

  Génère une quête originale pour la catégorie "#{category.name}" :
PROMPT


      begin
        response = client.chat(
  parameters: {
    model: "gpt-4-0613",
    messages: [
      { role: "system", content: "Tu es un générateur de quêtes immersives pour un jeu de leveling." },
      { role: "user", content: "#{prompt} La réponse doit être **courte et directe (max 2 phrases).**" }
    ],
    max_tokens: 100 # Réduit la longueur des quêtes
  }
)
puts "📜 Réponse OpenAI pour #{category.name} : #{response}"
quest_description = response.dig("choices", 0, "message", "content")&.strip || "Accomplis une tâche avancée dans la catégorie #{category.name}"

quest = WeeklyQuest.create!(
  title: "Challenge de #{category.name}",
  description: quest_description.strip,
  xp_reward: 500,
  category: category,
  valid_until: 7.days.from_now
)

User.find_each do |user|
  UserWeeklyQuest.create!(user: user, weekly_quest: quest)
end

        puts "✅ Quête générée pour #{category.name} : #{quest_description}"
      rescue => e
        puts "❌ Erreur lors de la génération de la quête pour #{category.name} : #{e.message}"
      end
    end

    puts "✅ Nouvelles quêtes hebdomadaires générées !"
  end
end
