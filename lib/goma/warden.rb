module Warden::Mixins::Common
  # To enable request.remote_ip in warden hooks.
  def request
    @request ||= ActionDispatch::Request.new(env)
  end
end
