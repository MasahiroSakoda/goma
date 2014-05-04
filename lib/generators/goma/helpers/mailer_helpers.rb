module Goma
  module Generators
    module MailerHelpers
    private
      def resource_name
        @resource_name ||= begin
          if options[:resource_name].present?
            options[:resource_name].underscore.to_sym
          elsif Goma.config.scopes.count == 1
            Goma.config.scopes.first
          else
            for scope in Goma.config.scopes
              break scope if name =~ /^#{scope}/i
            end
          end
        end
      end

      def goma_config
        @goma_config ||= Goma.config_for[resource_name.to_sym] || Goma.config
      end

      def goma_actions
        @goma_actions ||= begin
          a = ActiveSupport::OrderedHash.new
          if goma_config.modules.include?(:confirmable) &&
            name == (goma_config.activation_mailer_name || goma_config.default_mailer_name)
            a[:activation_needed_email] = 'Activation instructions'
            a[:activation_success_email] = 'Your account is now activated.'
            if goma_config.email_confirmation_enabled &&
              name == (goma_config.email_confirmation_mailer_name || goma_config.default_mailer_name)
              a[:email_confirmation_needed_email] = 'Email confirmation instructions'
              a[:email_confirmation_success_email] = 'Your email is now changed'
            end
          end

          if goma_config.modules.include?(:lockable) && goma_config.unlock_strategies.include?(:email) &&
            name == (goma_config.unlock_token_mailer_name || goma_config.default_mailer_name)
            a[:unlock_token_email] = 'Unlock instructions'
          end

          if goma_config.modules.include?(:recoverable) &&
            name == (goma_config.reset_password_mailer_name || goma_config.default_mailer_name)
            a[:reset_password_email] = 'Reset password instructions'
          end
          a
        end
      end
    end
  end
end
