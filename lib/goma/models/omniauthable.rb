module Goma
  module Models
    module Omniauthable
      extend ActiveSupport::Concern

      included do
        has_many goma_config.oauth_association_name, dependent: :destroy

        goma_config.oauth_authentication_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          belongs_to :#{goma_scope}#{self.to_s.underscore == goma_scope.to_s ? '' : ", class_name: '#{self}'"}
          validates_presence_of :#{goma_config.oauth_provider_attribute_name} , :#{goma_config.oauth_uid_attribute_name}
          validates_uniqueness_of :#{goma_config.oauth_uid_attribute_name}, scope: :#{goma_config.oauth_provider_attribute_name}

          def self.build_with_omniauth(omniauth)
            record = new
            record._fill_with_omniauth(omniauth)
            record
          end

          def _fill_with_omniauth(omniauth)
            self.#{goma_config.oauth_provider_attribute_name} = omniauth[:provider]
            self.#{goma_config.oauth_uid_attribute_name}      = omniauth[:uid]
            fill_with_omniauth(omniauth) if respond_to? :fill_with_omniauth
          end
        RUBY
      end

      module ClassMethods
        def create_with_omniauth!(omniauth)
          @creating_with_omniauth = true
          record = new
          if goma_config.modules.include? :confirmable
            record.send(goma_config.activated_at_setter, Time.now.utc)
          end
          record.fill_with_omniauth(omniauth)

          authentication = record.send(goma_config.oauth_association_name).build
          authentication._fill_with_omniauth(omniauth)

          record.save!
          record
        end

        def valid_except_email_or_password?
          if valid?
            true
          else
            errors.delete(goma_config.email_attribute_name)
            errors.delete(goma_config.password_attribute_name)
            errors.delete(goma_config.encrypted_password_attribute_name)
            errors.empty?
          end
        end
      end

      def fill_with_omniauth(omniauth)
      end
    end
  end
end
