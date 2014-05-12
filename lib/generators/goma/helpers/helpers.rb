module Goma
  module Generators
    module Helpers
      def base_name
        return 'Authentication' if options[:controller_type] == 'oauth'
        options[:controller_type]
      end

      def _resource_name
        if n = options[:resource_name]
          n
        else
          if (n = name.camelize.sub(/#{base_name}$/i, '')).present?
            n
          else
            Goma.config.default_scope.to_s
          end
        end
      end

      def resource_name
        @resource ||= _resource_name.underscore
      end

      def resource_class_name
        @resource_class ||= _resource_name.camelize
      end

      def goma_scope
        resource_name.to_sym
      end

      def goma_config
        @goma_config ||= Goma.config_for[goma_scope] || Goma.config
      end

      def resource_attributes
        goma_config.authentication_keys + [goma_config.password_attribute_name, goma_config.password_confirmation_attribute_name]
      end

      def specify_scope_if_needed
        goma_scope == Goma.config.default_scope ? '' : "#{goma_scope}_"
      end

      class << self
        attr_accessor :include_scope_name_into_controller_name
      end

      def longer_name?
        case Helpers.include_scope_name_into_controller_name
        when true
          return true
        when nil
          if options[:controller_type] != 'user' &&
            name =~ /^#{resource_class_name}/ || name =~ /^#{resource_name}/
            return true
          end
        end
        false
      end

      def login_url
        longer_name? ? "new_#{resource_name}_session_url" : "new_session_url"
      end
    end
  end
end

class Array
  def to_field_name
    self.to_sentence(words_connector: '_', two_words_connector: '_or_', last_word_connector: '_or_')
  end
end
