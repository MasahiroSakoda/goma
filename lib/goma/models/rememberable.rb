require 'goma/strategies/rememberable'
module Goma
  module Models
    module Rememberable
      extend ActiveSupport::Concern

      module ClassMethods
        def serialize_into_cookie(record)
          [record.to_key.first, record.rememberable_value]
        end

        def serialize_from_cookie(id, remember_token)
          record = find_by(primary_key => id)
          record if !record.remember_expired? &&
                    Goma.secure_compare(record.rememberable_value, remember_token)
        end
      end

      def serialize_into_cookie
        self.class.serialize_into_cookie(self)
      end

      def remember_me!
        send(goma_config.remember_token_setter, generate_remember_token) if generate_remember_token?
        send(goma_config.remember_created_at_setter, Time.now.utc) if generate_remember_timestamp?
        save(validate: false) if changed?
      end

      def forget_me!
        return unless persisted?
        send(goma_config.remember_token_setter, nil)
        send(goma_config.remember_created_at_setter, nil)
        save(validate: false)
      end

      def rememberable_value
        if respond_to?(:remember_token)
          send(goma_config.remember_token_getter)
        elsif salt = authenticatable_salt
          salt
        else
          raise "#{self.class}#authenticatable_salt returns nil."
        end
      end

      def remember_expired?
        send(goma_config.remember_created_at_getter).nil? || remember_expires_at <= Time.now.utc
      end

      def remember_expires_at
        send(goma_config.remember_created_at_getter) + goma_config.remember_for
      end

      def generate_remember_token
        loop do
          token = Goma.token_generator.friendly_token
          break token unless self.class.find_by(goma_config.remember_token_attribute_name => token)
        end
      end

    protected
      def generate_remember_token?
        goma_config.remember_token_attribute_name && remember_expired?
      end

      def generate_remember_timestamp?
        goma_config.extend_remember_period || remember_expired?
      end
    end
  end
end
