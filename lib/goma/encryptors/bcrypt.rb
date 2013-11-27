require 'bcrypt'

module Goma
  module Encryptors
    class Bcrypt
      class << self
        def encrypt(*tokens)
          ::BCrypt::Password.create(tokens.flatten.join, cost: Goma.config.stretches)
        end

        def valid_password?(encrypted_password, password)
          return false if encrypted_password.blank?

          bcrypt = ::BCrypt::Password.new(encrypted_password)
          password = ::BCrypt::Engine.hash_secret("#{password}#{Goma.config.pepper}", bcrypt.salt)
          Goma.secure_compare(password, encrypted_password)
        end
      end
    end
  end
end
