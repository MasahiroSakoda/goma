require 'openssl'
require 'securerandom'

module Goma
  class TokenGenerator
    def initialize(key_generator, digest='SHA256')
      @key_generator = key_generator
      @digest = digest
    end

    def digest(column, value)
      value.present? && OpenSSL::HMAC.hexdigest(@digest, key_for(column), value.to_s)
    end

    def generate(klass, column)
      key = key_for(column)

      loop do
        raw = friendly_token
        enc = OpenSSL::HMAC.hexdigest(@digest, key, raw)
        break [raw, enc] unless klass.find_by(column => enc)
      end
    end

    def friendly_token
      SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end

    private
    def key_for(column)
      @key_generator.generate_key("Goma #{column}")
    end
  end
end
