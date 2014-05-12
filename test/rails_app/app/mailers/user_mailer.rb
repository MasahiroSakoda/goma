class UserMailer < ActionMailer::Base
  default from: "please-change-me-at-config-initializers-goma@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    mail to: @user.email,
         subject: "Activation instructions"
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    mail to: @user.email,
         subject: "Your account is now activated."
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.email_confirmation_needed_email.subject
  #
  def email_confirmation_needed_email(user)
    @user = user
    mail to: @user.email,
         subject: "Email confirmation instructions"
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.email_confirmation_success_email.subject
  #
  def email_confirmation_success_email(user)
    @user = user
    mail to: @user.email,
         subject: "Your email is now changed"
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.unlock_token_email.subject
  #
  def unlock_token_email(user)
    @user = user
    mail to: @user.email,
         subject: "Unlock instructions"
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    mail to: @user.email,
         subject: "Reset password instructions"
  end


end
