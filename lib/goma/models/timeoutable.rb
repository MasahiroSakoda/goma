module Goma
  module Models
    module Timeoutable
      def timeout?(last_request_at)
        false if remember_exists_and_not_expired?
        goma_config.timeout_in && last_request_at && last_request_at <= goma_config.timeout_in.ago
      end

    private
      def remember_exists_and_not_expired?
        rememberable? && !remember_expired?
      end
    end
  end
end
