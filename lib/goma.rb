module Goma
  class << self
    attr_accessor :encryptor, :token_generator
    # TODO Where is the best place?
    def secure_compare(a, b)
     return false if a.blank? || b.blank? || a.bytesize != b.bytesize
     l = a.unpack "C#{a.bytesize}"

     res = 0
     b.each_byte { |byte| res |= byte ^ l.shift }
     res == 0
    end

    def incarnate(scope)
     @models ||= {}
     @models[scope] ||= scope.to_s.classify.constantize
    end
  end
  MODULES = [:validatable, :password_authenticatable, :lockable, :confirmable, :recoverable, :rememberable, :timeoutable, :trackable, :omniauthable]
  CONTROLLER_MODULES = [:password_authenticatable, :confirmable, :rememberable, :trackable, :timeoutable]

  InvalidIdOrPassword = Class.new(StandardError)
  NotActivated        = Class.new(StandardError)
  TokenExpired        = Class.new(StandardError)
end

require 'rails'

require 'goma/config'
require 'goma/token_generator'
require 'goma/test_helpers' if Rails.env == 'test'

require 'goma/railtie'
