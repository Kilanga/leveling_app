class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur Leveling App !")
  end

  def welcome_day3_email(user)
    @user = user
    mail(to: @user.email, subject: "Continue ton aventure Leveling 🎮")
  end

  def welcome_day7_email(user)
    @user = user
    mail(to: @user.email, subject: "Discover your stats on Leveling 📊")
  end

  def streak_reminder_email(user)
    @user = user
    @days_left = (Date.current.end_of_week - Date.current).to_i + 1
    mail(to: @user.email, subject: I18n.t("mailers.streak_reminder.subject", count: user.weekly_streak_count))
  end

  def purchase_confirmation(user:, summary:, amount_eur: nil)
    @user = user
    @summary = summary
    @amount_eur = amount_eur

    mail(to: @user.email, subject: "Confirmation d'achat - Leveling")
  end
end
