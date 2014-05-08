module Goma
  module Controllers
    module PasswordAuthenticatable
      extend ActiveSupport::Concern

      Goma.config.scopes.each do |scope|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{scope}_login(*args)
          login(*args, scope: :#{scope})
        end

        def #{scope}_login!(*args)
          login!(*args, scope: :#{scope})
        end
        RUBY
      end

      def login(identifier, password, remember_me=false, scope: Goma.config.default_scope)
        record = Goma.incarnate(scope).find_by_identifier(identifier)

        _goma_error[scope] = :invalid_id_or_password and return unless record

        if record.valid_password?(password)
          force_login(record, remember_me)
          record
        else
          _goma_error[scope] = record.goma_error || :invalid_id_or_password
          nil
        end
      end

      def login!(*args, scope: Goma.config.default_scope)
        unless record = login(*args, scope: scope)
          raise Goma::InvalidIdOrPassword if _goma_error[scope] == :invalid_id_or_password
          raise Goma::NotActivated        if _goma_error[scope] == :not_activated
        end
        record
      end
    end
  end
end
