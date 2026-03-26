class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur Leveling App !")
  end

  def purchase_confirmation(user:, summary:, amount_eur: nil)
    @user = user
    @summary = summary
    @amount_eur = amount_eur

    mail(to: @user.email, subject: "Confirmation d'achat - Leveling")
  end
end
