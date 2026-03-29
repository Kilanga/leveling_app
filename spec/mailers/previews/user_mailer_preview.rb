# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.welcome_email(example_user)
  end

  def purchase_confirmation
    UserMailer.purchase_confirmation(
      user: example_user,
      summary: "Pack Orbes: +500",
      amount_eur: 20
    )
  end

  private

  def example_user
    User.first || User.new(email: "preview@example.com", pseudo: "preview")
  end
end
