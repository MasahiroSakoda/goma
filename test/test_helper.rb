# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../rails_app/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'orm/active_record.rb'

require 'fabrication'
Fabrication.configure do |config|
  config.path_prefix = Dir.pwd
end
require 'mocha/setup'
require 'shoulda-context'
require 'timecop'
require 'capybara/rails'

require 'minitest/ansi'
MiniTest::ANSI.use!
require 'byebug'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase
  def swap(object, values)
    original_values = {}
    values.each do |k, v|
      original_values[k] = object.send(k)
      object.send(:"#{k}=", v)
    end
    yield
  ensure
    original_values.each do |k, v|
      object.send(:"#{k}=", v)
    end
  end
end

class ActionController::TestCase
  include Warden::Test::ControllerHelpers
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def signed_cookie(key)
    controller.send(:cookies).signed[key]
  end

  def update_signed_cookies(data)
    data.each do |k, v|
      cookies[k.to_s] = generate_signed_cookie(v)
    end
  end

  def generate_signed_cookie(raw_cookie)
    request = ActionDispatch::TestRequest.new
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  def warden
    request.env['warden']
  end

  def current_user
    warden.user(scope: :user)
  end

  # for Capybara
  def _controller
    page.driver.request.env['action_controller.instance']
  end

  def _request
    _controller.request
  end

  def _session
    _request.session
  end

  def _warden
    _request.env['warden']
  end

  def _current_user
    _warden.user(scope: :user)
  end

  def _cookies
    _request.cookies
  end

  def _signed_cookie(key)
    _controller.send(:cookies).signed[key]
  end

  def _update_signed_cookies(data)
    data.each do |k, v|
      _cookies[k.to_s] = generate_signed_cookie(v)
    end
  end
end

OmniAuth.config.test_mode = true
