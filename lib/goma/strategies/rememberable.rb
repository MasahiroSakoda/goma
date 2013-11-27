module Goma
  module Strategies
    class Rememberable < Warden::Strategies::Base
      def valid?
        @remember_cookie = nil
        remember_cookie.present?
      end

      def authenticate!
        record = Goma.incarnate(scope).serialize_from_cookie(*remember_cookie)

        unless record
          cookies.delete(remember_key)
          return pass
        end

        success!(record)
      end

      def remember_key
        "remember_#{scope}_token"
      end

      def remember_cookie
        @remember_cookie ||= cookies.signed[remember_key]
      end

      def cookies
        request.cookie_jar
      end
    end
  end
end

Warden::Strategies.add(:rememberable, Goma::Strategies::Rememberable)
