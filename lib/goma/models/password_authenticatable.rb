module Goma
  module Models
    module PasswordAuthenticatable
      extend ActiveSupport::Concern

      included do
        password_attr = goma_config.password_attribute_name
        attr_reader password_attr

        class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{password_attr}=(new_#{password_attr})
          return if new_#{password_attr}.blank?
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
        def find_by_identifier(identifier)
          for key, value in filtered_hash(identifier)
            break if record = find_by(key => value)
          end
          record
        end

        def filtered_hash(identifier)
          hash = {}
          goma_config.authentication_keys.each do |key|
            value = identifier.dup
            value.downcase! if key.in? goma_config.case_insensitive_keys
            value.strip! if key.in? goma_config.strip_whitespace_keys
            hash[key] = value
          end
          hash
        end
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
