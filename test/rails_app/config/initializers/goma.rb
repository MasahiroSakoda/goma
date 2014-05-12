Goma.configure do |config|
  # config.default_mailer_name = 'UserMailer'
  config.mailer_sender = 'please-change-me-at-config-initializers-goma@example.com'
  # config.clean_up_csrf_token_on_authentication = true
  config.secret_key = '35b9065416e971821b077ccb9466a98f3f3ef063e259bd48edf6e64bcb13cbebb19279678019ae62ca84e66b5b8214770750a1efa7f9a0cf4a0475a3283e8cfa'
  # config.serialization_method = :goma
  # config.scopes = [:user]
  # config.default_scope = :user
  #
  # Select modules you need. All modules are included by default.
  config.modules = [:password_authenticatable, :validatable, :confirmable, :rememberable, :timeoutable, :lockable, :trackable, :omniauthable]
  # config.save_return_to_url = true
  # config.not_authenticated_action = :not_authenticated


  ####################################################
  # Password authenticatable
  config.authentication_keys = [ :username, :email ]
  # config.case_insensitive_keys = [ :email ]
  # config.strip_whitespace_keys = [ :email ]
  # config.encryptor = :bcrypt
  # config.pepper = 'd7565a3070d7b7852de524f4c7b1159c8b58290e5427db80c4714f75da044a8f4af1e20d30c8af74cd21b90b3b9956b529bb805f95fac0ecda199e6ef5b62fac'
  config.stretches = Rails.env.test? ? 1 : 10
  # config.email_attribute_name = :email
  # config.password_attribute_name = :password
  # config.encrypted_password_attribute_name = :encrypted_password

  ####################################################
  # Validatable
  # config.password_length = 8..128
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  ####################################################
  # Confirmable
  # config.activation_mailer_name = nil
  # config.email_confirmation_mailer_name = nil
  # config.confirmation_keys = [ :email ]
  # config.allow_unconfirmed_access_for = 0
  # config.activate_within = 3.days
  # config.activation_needed_email_method_name = :activation_needed_email
  # config.activation_success_email_method_name = :activation_success_email
  # config.email_confirmation_enabled = true
  # config.confirm_email_within = 3.days
  # config.email_confirmation_needed_email_method_name = :email_confirmation_needed_email
  # config.email_confirmation_success_email_method_name = :email_confirmation_success_email
  # config.confirmation_token_attribute_name = :confirmation_token
  # config.confirmation_token_sent_at_attribute_name = :confirmation_token_sent_at
  # config.confirmation_token_to_send_attribute_name = :raw_confirmation_token
  # config.activated_at_attribute_name = :activated_at
  # config.unconfirmed_email_attribute_name = :unconfirmed_email
  # config.email_confirmed_at_attribute_name = nil

  ####################################################
  # Rememberable
  # config.remember_for = 2.weeks
  # config.extend_remember_period = false
  # config.rememberable_options = {}
  # config.remember_token_attribute_name = nil
  # config.remember_created_at_attribute_name = :remember_created_at


  ####################################################
  # Timeoutable
  # config.timeout_in = 30.minutes
  # config.logout_all_scopes = false
  # config.validate_session_even_in_not_login_area = true

  ####################################################
  # Lockable
  # config.unlock_token_mailer_name = nil
  # config.unlock_token_email_method_name = :unlock_email
  # config.lock_strategy = :failed_attempts
  # config.unlock_keys = [ :email ]
  # config.unlock_strategies = [ :email, :time ]
  # config.maximum_attempts = 20
  # config.failed_attempts_attribute_name = :failed_attempts
  # config.locked_at_attribute_name = :locked_at
  # config.unlock_in = 1.hour
  # config.last_attempt_warning = false # TODO not yet implemented
  # config.unlock_token_attribute_name = :unlock_token
  # config.unlock_token_sent_at_attribute_name = :unlock_token_sent_at
  # config.unlock_token_to_send_attribute_name = :raw_unlock_token

  ####################################################
  # Recoverable
  # config.reset_password_mailer_name = nil
  # config.reset_password_email_method_name = :reset_password_email
  # config.reset_password_keys = [ :email ]
  # config.reset_password_within = 6.hours
  # config.reset_password_token_attribute_name = :reset_password_token
  # config.reset_password_token_sent_at_attribute_name = :reset_password_token_sent_at
  # config.reset_password_token_to_send_attribute_name = :raw_reset_password_token

  ####################################################
  # Trackable
  # config.login_count_attribute_name = :login_count
  # config.current_login_at_attribute_name = :current_login_at
  # config.last_login_at_attribute_name = :last_login_at
  # config.current_login_ip_attribute_name = :current_login_ip
  # config.last_login_ip_attribute_name = :last_login_ip

  ####################################################
  # Omniauthable
  # config.oauth_authentication_class_name = 'Authentication'
  # config.oauth_provider_attribute_name = :provider
  # config.oauth_uid_attribute_name = :uid
end

# Scope specific configuration
# Goma.configure_for(:user) do |config|
  # -- scope specifig configurations goes here --
# end
