module Goma
  module Models
    module Confirmable
      extend ActiveSupport::Concern

      included do
        attr_accessor goma_config.confirmation_token_to_send_attribute_name

        before_create :setup_activation, unless: :activated?
        after_create  :send_activation_needed_email, if: :send_activation_needed_email?
        before_update :setup_email_confirmation, if: :email_confirmation_required?
        after_update  :send_email_confirmation_needed_email, if: :send_email_confirmation_needed_email?
      end

      # @!parse extend ClassMethods
      module ClassMethods
        DefinitionHelper.define_load_from_token_with_error_method_for(self, :confirmation)

        def load_from_activation_token_with_error(raw_token)
          load_from_confirmation_token_with_error(raw_token, goma_config.activate_within)
        end

        def load_from_email_confirmation_token_with_error(raw_token)
          load_from_confirmation_token_with_error(raw_token, goma_config.confirm_email_within)
        end

        DefinitionHelper.define_load_from_token_methods_for(self, :activation)
        DefinitionHelper.define_load_from_token_methods_for(self, :email_confirmation)
      end

      def initialize(*args)
        super
        @email_confirmation_setup              = false
        @skip_email_confirmation               = false

        # Following instance variables are not used by this library.
        # They may be used by someone who wants to change the default behavior.
        @skip_activation_needed_email          = false
        @skip_activation_success_email         = false
        @skip_email_confirmation_needed_email  = false
        @skip_email_confirmation_success_email = false
      end

      def activated?
        !!self.send(goma_config.activated_at_getter)
      end

      # Usually, this method should be called after user is loaded by
      # {ClassMethods#load_from_activation_token_with_error}.
      def activate!
        self.send(goma_config.activated_at_setter, Time.new.utc)
        self.send(goma_config.confirmation_token_setter, nil)
        self.send(goma_config.confirmation_token_sent_at_setter, nil)
        save!
        send_activation_success_email if send_activation_success_email?
      end

      # Usually, this method should be called after user is loaded by
      # {ClassMethods#load_from_email_confirmation_token_with_error}.
      def confirm_email!
        @skip_email_confirmation = true
        self.send(goma_config.email_setter, self.send(goma_config.unconfirmed_email_getter))
        self.send(goma_config.unconfirmed_email_setter, nil)
        self.send(goma_config.confirmation_token_setter, nil)
        self.send(goma_config.confirmation_token_sent_at_setter, nil)
        self.send(goma_config.email_confirmed_at_setter, Time.new.utc) if goma_config.email_confirmed_at_attribute_name
        save!
        send_email_confirmation_success_email if send_email_confirmation_success_email?
      ensure
        @skip_email_confirmation = false
      end

      def unactivated_access_allowed_period?
        period = goma_config.allow_unconfirmed_access_for
        return false if period == 0

        Time.now - created_at < period ? true : false
      end

      def email_confirmation_required?
        goma_config.email_confirmation_enabled && self.send(goma_config.email_changed_getter) && !@skip_email_confirmation
      end

      def send_activation_needed_email?
        goma_config.activation_needed_email_method_name && !@skip_activation_needed_email
      end

      def send_activation_success_email?
        goma_config.activation_success_email_method_name && !@skip_activation_success_email
      end

      def send_email_confirmation_needed_email?
        @email_confirmation_setup && goma_config.email_confirmation_needed_email_method_name && !@skip_email_confirmation_needed_email
      end

      def send_email_confirmation_success_email?
        goma_config.email_confirmation_success_email_method_name && !@skip_email_confirmation_success_email
      end

      DefinitionHelper.define_token_generator_method_for(self, :confirmation)

      protected
      def setup_activation
        generate_confirmation_token
      end

      def setup_email_confirmation
        self.send(Goma.config.unconfirmed_email_setter, self.send(Goma.config.email_getter))
        self.send(Goma.config.email_setter, self.send(Goma.config.email_was_getter))
        @email_confirmation_setup = true

        generate_confirmation_token
      end

      {activation_needed_email:          :activation,
       activation_success_email:         :activation,
       email_confirmation_needed_email:  :email_confirmation,
       email_confirmation_success_email: :email_confirmation}.each do |name, mailer_name|
        DefinitionHelper.define_send_email_method_for(self, mailer_name, name)
      end
    end
  end
end
