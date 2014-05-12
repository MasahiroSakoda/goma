module Goma
  class << self
    def configure(&block)
      yield @config ||= Goma::Configuration.new
    end

    def config
      @config
    end

    def configure_for(scope, &block)
      yield config_for[scope] = config.dup
    end

    def config_for
      @config_for ||= {}
    end
  end

  module Configurable
    extend ActiveSupport::Concern
    module ClassMethods
      def config_accessor(name)
        attr_accessor name
        if block_given?
          _initializers << Proc.new{ |i| i.send("#{name}=", yield) }
        end
      end

      def _initializers
        @_initializers ||= []
      end
    end

    def initialize
      super
      self.class._initializers.each{ |initializer| initializer.call(self) }
    end
  end

  class Configuration
    include Goma::Configurable
    config_accessor(:default_mailer_name)                          { 'UserMailer' }
    config_accessor(:mailer_sender)
    config_accessor(:clean_up_csrf_token_on_authentication)        { true }
    config_accessor(:secret_key)
    config_accessor(:serialization_method)                         { :goma }
    config_accessor(:scopes)                                       { [:user] }
    config_accessor(:default_scope)                                { :user }
    config_accessor(:modules)                                      { [] }
    config_accessor(:save_return_to_url)                           { true }
    config_accessor(:not_authenticated_action)                     { :not_authenticated }


    # Password authenticatable
    config_accessor(:authentication_keys)                          { [:email] }
    config_accessor(:case_insensitive_keys)                        { [:email] }
    config_accessor(:strip_whitespace_keys)                        { [:email] }
    config_accessor(:encryptor)                                    { :bcrypt }
    config_accessor(:pepper)
    config_accessor(:stretches)                                    { 10 }
    config_accessor(:email_attribute_name)                         { :email }
    config_accessor(:password_attribute_name)                      { :password }
    config_accessor(:encrypted_password_attribute_name)            { :encrypted_password }

    # Validatable
    config_accessor(:password_length)                              { 8..128 }
    config_accessor(:email_regexp)                                 { /\A[^@]+@[^@]+\z/ }

    # Confirmable
    config_accessor(:activation_mailer_name)                       { nil }
    config_accessor(:email_confirmation_mailer_name)               { nil }
    config_accessor(:confirmation_keys)                            { [ :email ] }
    config_accessor(:allow_unactivated_access_for)                 { 0 }
    config_accessor(:activate_within)                              { 3.days }
    config_accessor(:activation_needed_email_method_name)          { :activation_needed_email }
    config_accessor(:activation_success_email_method_name)         { :activation_success_email }
    config_accessor(:email_confirmation_enabled)                   { true }
    config_accessor(:confirm_email_within)                         { 3.days }
    config_accessor(:email_confirmation_needed_email_method_name)  { :email_confirmation_needed_email }
    config_accessor(:email_confirmation_success_email_method_name) { :email_confirmation_success_email }
    config_accessor(:confirmation_token_attribute_name)            { :confirmation_token }
    config_accessor(:confirmation_token_sent_at_attribute_name)    { :confirmation_token_sent_at }
    config_accessor(:confirmation_token_to_send_attribute_name)    { :raw_confirmation_token }
    config_accessor(:activated_at_attribute_name)                  { :activated_at }
    config_accessor(:unconfirmed_email_attribute_name)             { :unconfirmed_email }
    config_accessor(:email_confirmed_at_attribute_name)            { nil }

    # Rememberable
    config_accessor(:remember_for)                                 { 2.weeks }
    config_accessor(:extend_remember_period)                       { false }
    config_accessor(:rememberable_options)                         { {} }
    config_accessor(:remember_token_attribute_name)                { nil }
    config_accessor(:remember_created_at_attribute_name)           { :remember_created_at }

    # Timeoutable
    config_accessor(:timeout_in)                                   { 30.minutes }
    config_accessor(:logout_all_scopes)                            { false }
    config_accessor(:validate_session_even_in_not_login_area)      { true }

    # Lockable
    config_accessor(:unlock_token_mailer_name)                     { nil }
    config_accessor(:unlock_token_email_method_name)               { :unlock_token_email }
    config_accessor(:lock_strategy)                                { :failed_attempts }
    config_accessor(:unlock_keys)                                  { :email }
    config_accessor(:unlock_strategies)                            { [:email, :time] }
    config_accessor(:maximum_attempts)                             { 20 }
    config_accessor(:failed_attempts_attribute_name)               { :failed_attempts }
    config_accessor(:locked_at_attribute_name)                     { :locked_at }
    config_accessor(:unlock_in)                                    { 1.hour }
    config_accessor(:unlock_token_attribute_name)                  { :unlock_token }
    config_accessor(:unlock_token_sent_at_attribute_name)          { :unlock_token_sent_at }
    config_accessor(:unlock_token_to_send_attribute_name)          { :raw_unlock_token }

    # Recoverable
    config_accessor(:reset_password_mailer_name)                   { nil }
    config_accessor(:reset_password_email_method_name)             { :reset_password_email }
    config_accessor(:reset_password_keys)                          { [ :email ] }
    config_accessor(:reset_password_within)                        { 6.hours }
    config_accessor(:reset_password_token_attribute_name)          { :reset_password_token }
    config_accessor(:reset_password_token_sent_at_attribute_name)  { :reset_password_token_sent_at }
    config_accessor(:reset_password_token_to_send_attribute_name)  { :raw_reset_password_token }

    # Trackable
    config_accessor(:login_count_attribute_name)                   { :login_count }
    config_accessor(:current_login_at_attribute_name)              { :current_login_at }
    config_accessor(:last_login_at_attribute_name)                 { :last_login_at }
    config_accessor(:current_login_ip_attribute_name)              { :current_login_ip }
    config_accessor(:last_login_ip_attribute_name)                 { :last_login_ip }

    # Omniauthable
    config_accessor(:oauth_authentication_class_name)              { 'Authentication' }
    config_accessor(:oauth_provider_attribute_name)                { :provider }
    config_accessor(:oauth_uid_attribute_name)                     { :uid }


    self.instance_methods(false).grep(/attribute_name$/).each do |conf_name|
      name = conf_name.to_s[0...-15]

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
      alias :#{name}_getter :#{conf_name}
      def #{name}_setter
        @#{name}_setter ||= "\#{#{name}_getter}=".to_sym
      end

      def #{name}_changed_getter
        @#{name}_changed_getter ||= "\#{#{name}_getter}_changed?".to_sym
      end

      def #{name}_was_getter
        @#{name}_was_getter ||= "\#{#{name}_getter}_was".to_sym
      end
      RUBY
    end

    def password_confirmation_attribute_name
      @password_confirmation_attribute_name ||= "#{password_attribute_name}_confirmation".to_sym
    end

    def oauth_association_name
      @oauth_association_name ||=
        oauth_authentication_class_name ? oauth_authentication_class_name.underscore.pluralize.to_sym : ''
    end

    def oauth_authentication_class
      @oauth_authentication_class ||= oauth_authentication_class_name.constantize
    end
  end
end
