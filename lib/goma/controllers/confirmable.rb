module Goma
  module Controllers
    module Confirmable
      def login(identifier, password, remember_me=false, scope: Goma.config.default_scope)
        record = super
        if record && record.goma_config.modules.include?(:confirmable)
          if record.activated? || record.unactivated_access_allowed_period?
            record
          else
            warden.logout(scope)
            _goma_error[scope] = :not_activated
            nil
          end
        else
          record
        end
      end
    end
  end
end
