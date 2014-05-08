module Goma
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      module ClassMethods
        Goma::MODULES.each do |mod|
          class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{mod}?
            goma_config.modules.include?(:#{mod})
          end
          METHOD
        end

        def goma_scope
          @goma_scope ||= begin
                            _goma_scope = name.underscore.to_sym
                            if _goma_scope.in?(Goma.config.scopes)
                              _goma_scope
                            elsif superclass.try(:goma_scope).in?(Goma.config.scopes)
                              superclass.goma_scope
                            else
                              Goma.config.default_scope
                            end
                          end
        end

        def goma_config
          @goma_config ||= Goma.config_for[self.goma_scope] || Goma.config
        end

        def load_from_token_with_error(raw_token, token_attr, token_sent_at_attr, valid_period)
          token = Goma.token_generator.digest(token_attr, raw_token)
          if record = self.find_by(token_attr => token)
            if Time.new.utc - record.send(token_sent_at_attr) <= valid_period
              [record, nil]
            else
              [nil, :token_expired]
            end
          else
            [nil, :not_found]
          end
        end
      end

      attr_accessor :goma_error

      Goma::MODULES.each do |mod|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{mod}?
          self.class.#{mod}?
        end
        METHOD
      end

      def goma_config
        self.class.goma_config
      end

      def goma_scope
        self.class.goma_scope
      end

      def authenticatable_salt
      end
    end
  end

  module DefinitionHelper
    class << self
      # class methods

      def define_load_from_token_with_error_method_for(target, purpose)
        target.module_eval <<-METHOD, __FILE__, __LINE__ + 1
        def load_from_#{purpose}_token_with_error(raw_token, valid_period)
          token_attr = goma_config.#{purpose}_token_attribute_name
          token_sent_at_attr = goma_config.#{purpose}_token_sent_at_attribute_name
          load_from_token_with_error(raw_token, token_attr, token_sent_at_attr, valid_period)
        end
        METHOD
      end

      def define_load_from_token_methods_for(target, purpose)
        target.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def load_from_#{purpose}_token!(raw_token)
          record, error = load_from_#{purpose}_token_with_error(raw_token)
          unless record
            case error
            when :not_found
              raise Goma::NotFound
            when :token_expired
              raise Goma::TokenExpired
            end
          end
          record
        end

        def load_from_#{purpose}_token(raw_token)
          load_from_#{purpose}_token_with_error(raw_token).first
        end
        RUBY
      end

      # instance methods

      def define_token_generator_method_for(target, purpose)
        target.module_eval <<-METHOD, __FILE__, __LINE__ + 1
        def generate_#{purpose}_token
          raw, enc = Goma.token_generator.generate(self.class, goma_config.#{purpose}_token_attribute_name)
          self.send(goma_config.#{purpose}_token_to_send_setter, raw)
          self.send(goma_config.#{purpose}_token_setter, enc)
          self.send(goma_config.#{purpose}_token_sent_at_setter, Time.now.utc)
        end
        METHOD
      end

      def define_send_email_method_for(target, mailer_name, name)
        target.module_eval <<-METHOD, __FILE__, __LINE__ + 1
        def send_#{name}
          mailer = (goma_config.#{mailer_name}_mailer_name || goma_config.default_mailer_name).constantize
          mailing_method = goma_config.#{name}_method_name
          mail = mailer.send(mailing_method, self)
          mail.deliver
        end
        METHOD
      end
    end
  end
end
