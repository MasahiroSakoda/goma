module Goma
  module Controllers
    module Trackable
      extend ActiveSupport::Concern

      module ClassMethods
        def skip_trackable(*args)
          prepend_before_action :skip_trackable, *args
        end
      end

      def skip_trackable
        request.env['goma.skip_trackable'] = true
      end
    end
  end
end
