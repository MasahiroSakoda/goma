Goma.configure do |config|
  # config.default_mailer =
  config.mailer_sender = 'please-change-me-at-config-initializers-goma@example.com'
  # config.authentication_keys = [ :email ]
  # config.email_regexp = /\A[^@]+@[^@]+\z/
  # config.case_insensitive_keys = [ :email ]
  # config.strip_whitespace_keys = [ :email ]
  # config.clean_up_csrf_token_on_authentication = true
  config.secret_key = '<%= SecureRandom.hex(64) %>'
  # config.encryptor = :bcrypt
  config.stretches = Rails.env.test? ? 1 : 10
  # config.pepper = '<%= SecureRandom.hex(64) %>'
  # config.serialization_method = :devise
  # config.scopes = [:user]
  # config.default_scope = :user
  # config.modules = [:password_authenticatable]

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
  # config.activation_needed_email_method_name = :activation_needed_email
  # config.activation_success_email_method_name = :activation_success_email
  # config.email_confirmation_enabled = true
  # config.confirm_email_within = 3.days
  # config.email_confirmation_needed_email_method_name = :email_confirmation_needed_email
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
  # config.logout_all_scopes = false

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
  # config.omniauth :developer if Rails.env.in? ['development', 'test']
  # config.omniauth :twitter, 'APP_ID', 'APP_SECRET'
  #
  # config.oauth_authentication_class_name = 'Authentication'
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
