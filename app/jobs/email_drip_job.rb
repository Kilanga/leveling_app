class EmailDripJob < ApplicationJob
  queue_as :default
  # Ce job envoie les emails de bienvenue automatiquement à J+3 et J+7
  # À déclencher manuellement ou via un cronjob
  # Exemple: EmailDripJob.set(wait: 3.days).perform_later(user.id, 'day3')
  # ou via config/recurring.yml pour Solid Queue

  def perform(user_id, step)
    user = User.find_by(id: user_id)
    return unless user

    case step
    when 'day3'
      UserMailer.welcome_day3_email(user).deliver_now
    when 'day7'
      UserMailer.welcome_day7_email(user).deliver_now
    end
  end
end
