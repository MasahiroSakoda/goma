module Goma
  module Controllers
    module Timeoutable
      extend ActiveSupport::Concern

      included do
        if Goma.config.validate_session_even_in_not_login_area
          prepend_before_action :validate_session
        end
      end

      module ClassMethods
        # If user accessed an action which specified by skip_validate_session,
        # goma would skip session validation check and keep user log in
        # even if the session passed the time limit.
        # However, goma does not update last_request_at.
        def skip_validate_session(*args)
          if Goma.config.validate_session_even_in_not_login_area
            skip_before_action :validate_session, *args
          else
            prepend_before_action :skip_validate_session, *args
          end
        end

        # If user accessed an action which specified by skip_timeout,
        # goma would keep user log in and update last_request_at
        # even if the session passed the time limit.
        def skip_timeout(*args)
          prepend_before_action :skip_timeout, *args
        end
      end

      attr_accessor :goma_skip_validate_session, :goma_skip_timeout

      def force_login(record, *)
        if super
          warden.session(record.goma_scope)['goma.last_request_at'] = Time.now.utc.to_i
          record
        end
      end

      def skip_validate_session
        self.goma_skip_validate_session = true
      end

      def skip_timeout
        self.goma_skip_timeout = true
      end

      def validate_session
        Goma.config.scopes.each do |scope|
          validate_session_for(scope)
        end
      end

      def validate_session_for(scope)
        return if goma_skip_validate_session
        return unless record = warden.user(scope)

        last_request_at = warden.session(scope)['goma.last_request_at']
        last_request_at = Time.at(last_request_at).utc if last_request_at

        if record.timeout?(last_request_at) && !goma_skip_timeout
          _goma_error[scope] = :timeout
        elsif !request.env['goma.skip_trackable']
          warden.session(scope)['goma.last_request_at'] = Time.now.utc.to_i
        end
      end

      Goma.config.scopes.each do |scope|
        config = Goma.config_for[scope] || Goma.config
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def require_#{scope}_login
          #{Goma.config.validate_session_even_in_not_login_area ? '' : "validate_session_for(:#{scope})" }
          if _goma_error[:#{scope}] == :timeout
            #{config.logout_all_scopes ? 'logout_all_scopes(timeout: true)' : "logout(:#{scope}, timeout: true)"}
          end
          super
        end
        RUBY
      end
    end
  end
end
