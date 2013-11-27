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


      def remember_me!(record)
        return if goma_skip_storage
        record.remember_me!
        cookies.signed[remember_cookie_key(record)] = remember_cookie_value(record)
      end

      def remember_cookie_key(record)
        "remember_#{record.goma_scope}_token"
      end

      def remember_cookie_value(record)
        {httponly: true}.
          merge( Rails.configuration.session_options.slice(:path, :domain, :secure) ).
          merge( record.goma_config.rememberable_options ).
          merge( value:   record.serialize_into_cookie,
                 expires: record.remember_expires_at)
      end
    end
  end
end
