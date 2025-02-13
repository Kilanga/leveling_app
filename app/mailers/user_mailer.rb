class UserMailer < ApplicationMailer
  default from: "noreply@arnaudlothe.eu"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur Leveling App !")
  end
end
