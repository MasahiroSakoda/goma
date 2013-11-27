require 'goma/hooks/trackable'

module Goma
  module Models
    module Trackable
      def update_tracked_fields!(request)
        old_current, new_current = self.current_login_at, Time.now.utc
        self.last_login_at = old_current || new_current
        self.current_login_at = new_current

        old_current, new_current = self.current_login_ip, request.remote_ip
        self.last_login_ip= old_current || new_current
        self.current_login_ip = new_current

        self.login_count ||= 0
        self.login_count += 1

        save(validate: false) or raise "Goma trackable could not save #{inspect}." \
          "Please make sure a model using trackable can be saved at login."
      end
    end
  end
end
