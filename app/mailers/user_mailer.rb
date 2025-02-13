class UserMailer < ApplicationMailer
  default from: "no-reply@ton-domaine.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur Leveling App !")
  end
end
