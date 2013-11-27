module Goma
  module Models
    module PasswordAuthenticatable
      extend ActiveSupport::Concern

      included do
        password_attr = goma_config.password_attribute_name
        attr_reader password_attr, "current_#{password_attr}"
        attr_accessor "#{password_attr}_confirmation"

        class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{password_attr}=(new_#{password_attr})
          @#{password_attr} = new_#{password_attr}
          self.#{Goma.config.encrypted_password_attribute_name} = encrypt_password(new_#{password_attr})
        end
        METHOD

        self.goma_config.case_insensitive_keys.each do |key|
          before_validation { |record| record.send(key).try(:downcase!) }
        end

        self.goma_config.strip_whitespace_keys.each do |key|
          before_validation { |record| record.send(key).try(:strip!) }
        end
      end

      module ClassMethods
      end

      def valid_password?(password)
        Goma.encryptor.valid_password?(self.send(goma_config.encrypted_password_getter), password)
      end

      def authenticatable_salt
        self.send(goma_config.encrypted_password_getter).try(:[], 0, 29)
      end

      protected
      def encrypt_password(password)
        Goma.encryptor.encrypt(password, Goma.config.pepper)
      end
    end
  end
end
