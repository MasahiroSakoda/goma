module Goma
  module Controllers
    extend ActiveSupport::Concern

    included do
      Goma.config.scopes.each do |scope|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def current_#{scope}
          @current_#{scope} ||= super
        end

        helper_method :current_#{scope}
        helper_method :#{scope}_logged_in?
        RUBY
      end
      helper_method :logged_in?
    end

    def warden
      request.env['warden']
    end

    def omniauth
      request.env['omniauth.auth']
    end

    Goma.config.scopes.each do |scope|
      config = Goma.config_for[scope] || Goma.config

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def current_#{scope}
        warden.authenticate(scope: :#{scope})
      rescue Goma::NotFound
        logout(:#{scope})
        nil
      end

      def #{scope}_logged_in?
        !!current_#{scope}
      end

      def #{scope}_logout
        logout(:#{scope})
      end

      def require_#{scope}_login
        return if #{scope}_logged_in?
        #{config.save_return_to_url ? "store_return_to_url(:#{scope}, request.url) if request.get?" : ''}
        #{config.not_authenticated_action}
      end

      def #{scope}_redirect_back_or_to(url, options={})
        redirect_back_or_to(url, options.merge!(scope: :#{scope}))
      end
      RUBY
    end

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
    alias logged_in? #{Goma.config.default_scope}_logged_in?
    def require_login
      require_#{Goma.config.default_scope}_login
    end
    RUBY

    def _goma_error
      @goma_error ||= {}
    end

    def goma_error(scope=nil)
      scope ? _goma_error[scope] : _goma_error[Goma.config.default_scope]
    end

    def force_login(record, *)
      warden.set_user(record, scope: record.goma_scope)
    end

    def logout(arg=nil, *)
      scope = case arg
              when Symbol
                arg
              when nil
                Goma.config.default_scope
              else
                arg.goma_scope
              end
      warden.logout(scope)
      instance_variable_set("@current_#{scope}", nil)
    end

    def logout_all_scopes(timeout: false)
      Goma.config.scopes.each { |scope| logout(scope, timeout: timeout) }
    end

    def redirect_back_or_to(url, options={})
      scope = options.delete(:scope) || Goma.config.default_scope
      redirect_to(return_to_url(scope, clear: true) || url, flash: options)
    end

    def store_return_to_url(scope, url)
      session[return_to_url_key(scope)] = url
    end

    def return_to_url(scope, clear: false)
      if clear
        session.delete(return_to_url_key(scope))
      else
        session[return_to_url_key(scope)]
      end
    end

    def return_to_url_key(scope)
      "#{scope}_return_to"
    end

    def not_authenticated
      redirect_to root_path
    end

  end
end
