Goma.configure do |config|
  config.default_mailer = UserMailer
  config.mailer_sender = 'please-change-me-at-config-initializers-goma@example.com'
  config.authentication_keys = [ :username, :email ]
  # config.email_regexp = /\A[^@]+@[^@]+\z/
  # config.password_length = 6..128
  # config.case_insensitive_keys = [ :email ]
  # config.strip_whitespace_keys = [ :email ]
  # config.clean_up_csrf_token_on_authentication = true
  config.secret_key = 'a4ab04a6c7760a89ab16803ffee4181a459a7ac7226b3c9e83391e459dc36a2fe926283cefb793753961a63f79944209efe615911afb3fbd4e92ae3858084578'
  # config.encryptor = :bcrypt
  config.stretches = Rails.env.test? ? 1 : 10
  # config.pepper = '50d0f3afd793f67bb0a3cee4de47f4f147e7d096aa05f5d9571c0db5d39c85e6d4efb182937fb2d490a6d07f0e46fc007ed703f42f8037f88f60b8086198df5b'
  # config.serialization_method = :goma
  # config.scopes = [:user]
  # config.default_scope = :user
  config.modules = [:password_authenticatable, :confirmable, :rememberable, :timeoutable, :lockable, :trackable, :omniauthable, :validatable]

  # config.email_attribute_name = :email
  # config.password_attribute_name = :password
  # config.encrypted_password_attribute_name = :encrypted_password

  ####################################################
  # Confirmable
  # config.mailer_for_activation = nil
  # config.mailer_for_email_confirmation = nil
  # config.confirmation_keys = [ :email ]
  # config.allow_unconfirmed_access_for = 0
  # config.activate_within = 3.days
  # config.send_activation_needed_email = true
  # config.activation_needed_email_method_name = :activation_needed_email
  # config.send_activation_success_email = true
  # config.activation_success_email_method_name = :activation_success_email
  # config.email_confirmation_enabled = true
  # config.confirm_email_within = 3.days
  # config.send_email_confirmation_needed_email = true
  # config.email_confirmation_needed_email_method_name = :email_confirmation_needed_email
  # config.send_email_confirmation_success_email = true
  # config.email_confirmation_success_email_method_name = :email_confirmation_success_email
  # config.confirmation_token_attribute_name = :perishable_token
  # config.confirmation_token_sent_at_attribute_name = :perishable_token_sent_at
  # config.activated_at_attribute_name = :activated_at
  # config.unconfirmed_email_attribute_name = :unconfirmed_email
  # config.email_confirmed_at_attribute_name = nil

  ####################################################
  # Rememberable
  # config.remember_for = 2.weeks
  # config.extend_remember_period = false
  # config.rememberable_options = {}


  ####################################################
  # Timeoutable
  # config.timeout_in = 30.minutes
  # config.expire_auth_token_on_timeout = false
  # config.validate_session_even_in_not_login_area = true

  ####################################################
  # Lockable
  # config.mailer_for_unlock = nil
  # config.lock_strategy = :failed_attempts
  # config.unlock_keys = [ :email ]
  # config.unlock_strategies = [ :email, :time ]
  # config.maximum_attempts = 20
  # config.unlock_in = 1.hour
  # config.last_attempt_warning = false
  # config.unlock_token_attribute_name = :unlock_token
  # config.unlock_token_sent_at_attribute_name = :unlock_token_sent_at

  ####################################################
  # Recoverable
  # config.mailer_for_password_reset = nil
  # config.reset_password_keys = [ :email ]
  # config.reset_password_within = 6.hours
  # config.reset_password_token_attribute_name = :reset_password_token
  # config.reset_password_token_sent_at_attribute_name = :reset_password_token_sent_at

  ####################################################
  # Omniauthable
  # No providers are registered by default.
  # ex.)
  config.omniauth :developer if Rails.env.in? ['development', 'test']
  # config.omniauth :twitter, 'APP_ID', 'APP_SECRET'
  #
  config.oauth_authentication_class_name = 'Authentication'
  # config.oauth_provider_attribute_name = :provider
  # config.oauth_uid_attribute_name = :uid


  ####################################################
  # Attribute names settings
  # config.salt_attribute_name = nil
  # config.salt_join_token = ''
end

# Scope specific configuration
# Goma.configure_for(:user) do |config|
# end
