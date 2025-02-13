class UserMailer < ApplicationMailer
  default from: "arnaud.lothe@gmail.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur Leveling App !")
  end
end
