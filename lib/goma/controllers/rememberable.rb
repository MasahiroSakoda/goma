module Goma
  module Controllers
    module Rememberable
      attr_accessor :goma_skip_storage

      def force_login(record, remember=false, scope: nil)
        if super(record, scope: scope)
          remember_me!(record) if remember.in? ['1', true, 1, 'true', 'TRUE', 't', 'T']
          record
        end
      end

      def logout(arg=nil, timeout: false)
        unless timeout
          record = if arg.nil? || arg.is_a?(Symbol)
                     warden.user(arg || Goma.config.default_scope)
                   else
                     arg
                   end
          forget_me!(record)
        end
        super
      end

      def remember_me!(record)
        return if goma_skip_storage
        record.remember_me!
        cookies.signed[remember_cookie_key(record)] = remember_cookie_value(record)
      end

      def forget_me!(record)
        record.forget_me!
        cookies.delete(remember_cookie_key(record), forget_cookie_values(record))
      end

      def remember_cookie_key(record)
        "remember_#{record.goma_scope}_token"
      end

      def remember_cookie_value(record)
        {httponly: true}.
          merge( forget_cookie_values(record) ).
          merge( value:   record.serialize_into_cookie,
                 expires: record.remember_expires_at)
      end

      def forget_cookie_values(record)
        Rails.configuration.session_options.slice(:path, :domain, :secure).
          merge(record.goma_config.rememberable_options)
      end
    end
  end
end
