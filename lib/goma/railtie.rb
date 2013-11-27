require 'active_support/inflector'
require 'warden'
require 'goma/warden'

module Goma
  class Railtie < ::Rails::Railtie
    config.app_middleware.use Warden::Manager do |config|
      if Goma.config && Goma.config.modules.include?(:rememberable)
        config.default_strategies :rememberable
      end
    end

    initializer 'goma' do |app|
      ActiveSupport.on_load(:active_record) do
        require 'goma/models'
        ActiveRecord::Base.send(:include, Goma::Models)
        Goma::NotFound = ActiveRecord::RecordNotFound
      end

      begin; require 'mongoid'; rescue LoadError; end
      if defined? ::Mongoid
        require 'goma/models'
        Goma::NotFound = Mongoid::Errors::DocumentNotFound
      end

      ActiveSupport.on_load(:action_controller) do
        next unless Goma.config
        require 'goma/controllers'
        ActionController::Base.send(:include, Goma::Controllers)

        (Goma::CONTROLLER_MODULES & Goma.config.modules).each do |mod|
          require "goma/controllers/#{mod}"
          ActionController::Base.send(:include, Goma::Controllers.const_get(mod.to_s.classify))
        end
      end
    end


    config.after_initialize do |app|
      next unless Goma.config
      if (Goma.config.modules & [:confirmable, :recoverable, :lockable]).present?
        require 'goma/mailer'
      end

      Goma.config.scopes.each do |scope|
        case Goma.config.serialization_method
        when :goma
          Warden::Manager.serialize_into_session(scope) do |record|
            [record.to_key.first, record.authenticatable_salt]
          end
          Warden::Manager.serialize_from_session(scope) do |keys|
            id, salt = keys
            klass = Goma.incarnate(scope)
            record = klass.find_by(klass.primary_key => id)
            record if record && record.authenticatable_salt == salt
          end
        when :devise
          Warden::Manager.serialize_into_session(scope) do |record|
            [record.to_key, record.authenticatable_salt]
          end
          Warden::Manager.serialize_from_session(scope) do |keys|
            key, salt = keys
            klass = Goma.incarnate(scope)
            record = klass.find_by(klass.primary_key => key.first)
            record if record && record.authenticatable_salt == salt
          end
        when /plain|sorcery/
          Warden::Manager.serialize_into_session(scope) do |record|
            record.to_key.first
          end
          Warden::Manager.serialize_from_session(scope) do |id|
            klass = Goma.incarnate(scope)
            klass.find_by(klass.primary_key => id)
          end
        end
      end

      Goma.token_generator ||=
        if secret_key = Goma.config.secret_key
          Goma::TokenGenerator.new(
            ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key))
          )
        end

      if Goma.config.modules.include?(:password_authenticatable) &&
        Goma.config.encryptor.present?
        require "goma/encryptors/#{Goma.config.encryptor.to_s.underscore}"
        Goma.encryptor ||=
          Goma::Encryptors.const_get(Goma.config.encryptor.to_s.classify)
      end

      if Goma.config.modules.include?(:omniauthable)
        config.app_middleware.use ::OmniAuth::Builder do
          Goma.config.oauth_providers.each do |service, oauth|
            provider(service) and next if service.to_sym == :developer
            provider service, oauth[:key], oauth[:secret]
          end
        end
      end

      require 'goma/routes'
    end
  end
end
