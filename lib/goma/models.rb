module Goma
  module Models
    extend ActiveSupport::Concern

    # @!parse extend ClassMethods
    module ClassMethods
      # Include {Goma::Models::Authenticatable} and other modules
      # specified in config/initializers/goma.rb file.
      #
      # @param [Symbol] goma_scope If goma_scope is omitted, Goma assumes
      #                            scope by the class name and configuration.
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
