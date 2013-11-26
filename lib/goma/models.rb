module Goma
  module Models
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def goma(options = {})
        require 'goma/models/authenticatable'
        include Goma::Models::Authenticatable
      end
    end
  end
end
