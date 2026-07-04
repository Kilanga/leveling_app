namespace :engagement do
  desc "Rappelle aux joueurs de valider une quête pour préserver leur streak hebdo (à lancer quotidiennement)"
  task streak_reminders: :environment do
    sent = StreakReminder.call
    puts "[engagement:streak_reminders] #{sent} rappel(s) envoyé(s)"
  end
end
