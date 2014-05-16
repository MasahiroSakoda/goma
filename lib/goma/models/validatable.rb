module Goma
  module Models
    module Validatable
      extend ActiveSupport::Concern

      included do
        if password_authenticatable?
          (goma_config.authentication_keys + [goma_config.email_attribute_name]).uniq.each do |key|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
            validates_presence_of   :#{key},                    if: :#{key}_required?
            validates_uniqueness_of :#{key}, allow_blank: true, if: :#{key}_changed?
            RUBY
            if omniauthable?
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{key}_required?
                !@creating_with_omniauth && #{goma_config.oauth_association_name}.empty?
              end
              RUBY
            else
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{key}_required?
                true
              end
              RUBY
            end
          end
          if goma_config.email_attribute_name && goma_config.email_regexp
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
            validates_format_of :#{goma_config.email_attribute_name},
                                with: goma_config.email_regexp, allow_blank: true, if: :email_changed?
            RUBY
          end

          validates_presence_of     goma_config.password_attribute_name, if: :password_required?
          validates_confirmation_of goma_config.password_attribute_name, if: :password_required?
          validates_length_of       goma_config.password_attribute_name,
                                    within: goma_config.password_length, allow_blank: true

          if omniauthable?
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def password_required?
              !@creating_with_omniauth && #{goma_config.oauth_association_name}.empty? && (
              !persisted? ||
              #{goma_config.password_attribute_name}.present? ||
              #{goma_config.password_confirmation_attribute_name}.present?)
            end
            RUBY
          else
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def password_required?
              !persisted? ||
              #{goma_config.password_attribute_name}.present? ||
              #{goma_config.password_confirmation_attribute_name}.present?
            end
            RUBY
          end
        end
      end
    end
  end
end
