module Goma
  module Models
    extend ActiveSupport::Concern

    module ClassMethods
      def goma(goma_scope=nil)
        @goma_scope = goma_scope if goma_scope
        require 'goma/models/authenticatable'
        include Goma::Models::Authenticatable

        (Goma::MODULES & goma_config.modules).each do |mod|
          require "goma/models/#{mod}"
          include Goma::Models.const_get(mod.to_s.classify)
        end
      end
    end
  end
end
