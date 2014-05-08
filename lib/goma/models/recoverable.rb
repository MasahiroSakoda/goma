module Goma
  module Models
    module Recoverable
      extend ActiveSupport::Concern

      module ClassMethods
        DefinitionHelper.define_load_from_token_with_error_method_for(self, :reset_password)
        DefinitionHelper.define_load_from_token_methods_for(self, :reset_password)
      end

      attr_accessor :raw_reset_password_token

      def send_reset_password_instructions!
        generate_reset_password_token
        save!
        send_reset_password_email
      end

      def change_password!(new_password, new_password_confirmation=nil)
        self.send(goma_config.reset_password_token_setter, nil)
        self.send(goma_config.reset_password_token_sent_at_setter, nil)
        self.send(goma_config.password_setter, new_password)
        self.send(goma_config.password_confirmation_setter, new_password_confirmation) if new_password_confirmation
        save!
      end

      DefinitionHelper.define_token_generator_method_for(self, :reset_password)
      DefinitionHelper.define_send_email_method_for(self, :reset_password, :reset_password_email)
    end
  end
end
