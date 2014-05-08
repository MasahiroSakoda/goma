require 'goma/hooks/lockable'

module Goma
  module Models
    module Lockable
      extend ActiveSupport::Concern

      included do
        attr_accessor goma_config.unlock_token_to_send_attribute_name
      end

      module ClassMethods
        DefinitionHelper.define_load_from_token_with_error_method_for(self, :unlock)
        DefinitionHelper.define_load_from_token_methods_for(self, :unlock)
      end


      def send_unlock_instructions!
        generate_unlock_token
        save!
        send_unlock_token_email
      end

      DefinitionHelper.define_token_generator_method_for(self, :unlock)
      DefinitionHelper.define_send_email_method_for(self, :unlock_token, :unlock_token_email)

      def valid_password?(password)
        if super
          @goma_error = :locked and return false if access_locked?
          true
        else
          self.send(goma_config.failed_attempts_setter, self.send(goma_config.failed_attempts_getter) + 1)
          if attempts_exceeded?
            lock_access!
          else
            save(validate: false)
          end
          false
        end
      end

      def lock_access!
        self.send(goma_config.locked_at_setter, Time.now.utc)

        if unlock_strategy_enabled?(:email)
          send_unlock_instructions!
        else
          save(validate: false)
        end
      end

      def unlock_access!
        self.send(goma_config.locked_at_setter, nil)
        self.send(goma_config.failed_attempts_setter, 0)
        self.send(goma_config.unlock_token_setter, nil)
        save(validate: false)
      end

      def access_locked?
        !!self.send(goma_config.locked_at_getter) && !lock_expired?
      end

      def lock_expired?
        if unlock_strategy_enabled?(:time)
          self.send(goma_config.locked_at_getter).try(:<, goma_config.unlock_in.ago)
        else
          false
        end
      end

      def last_attempt?
        self.send(goma_config.failed_attempts_getter) == goma_config.maximum_attempts
      end

      def attempts_exceeded?
        self.send(goma_config.failed_attempts_getter) > goma_config.maximum_attempts
      end

      def unlock_strategy_enabled?(strategy)
        strategy.in? goma_config.unlock_strategies
      end
    end
  end
end
