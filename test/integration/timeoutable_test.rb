require 'test_helper'

class TimeoutableTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
    post 'session', username_or_email: @user.email, password: 'password'
  end

  test "should set goma.last_request_at immediately after login" do
    assert request.env['warden'].session(:user)['goma.last_request_at']

    Timecop.freeze 30.minutes.from_now
    get 'secret/index'
    assert_redirected_to root_url

    Timecop.return
  end

  test "should timeout" do
    Timecop.freeze Time.now
    get 'secret/index'

    Timecop.freeze 29.minutes.from_now
    get 'secret/index'
    assert_response :success

    Timecop.freeze 30.minutes.from_now
    get 'secret/index'
    assert_redirected_to root_url

    Timecop.return
  end

  test "should not timeout if accessed a page which does not require login" do
    Timecop.freeze Time.now
    get 'secret/index'

    Timecop.freeze 20.minutes.from_now
    get '/'
    assert_response :success

    Timecop.freeze 20.minutes.from_now
    get 'secret/index'
    assert_response :success

    Timecop.return
  end

  test "should timeout if accessing skip_trackabled action" do
    Timecop.freeze Time.now
    get 'secret/index'

    Timecop.freeze 20.minutes.from_now
    get 'secret/not_track'
    assert_response :success

    Timecop.freeze 20.minutes.from_now
    get 'secret/not_track'
    assert_redirected_to root_url

    Timecop.return
  end

  test "should not timeout but update last_request_at by accessing skip_timeout action" do
    Timecop.freeze Time.now
    get 'secret/index'

    Timecop.freeze 60.minutes.from_now
    get 'secret/not_timeout'
    assert_response :success

    Timecop.freeze 29.minutes.from_now
    get 'secret/index'
    assert_response :success

    Timecop.freeze 60.minutes.from_now
    get 'secret/not_timeout'
    assert_response :success

    Timecop.freeze 30.minutes.from_now
    get 'secret/index'
    assert_redirected_to root_url

    Timecop.return
  end

  test "should not timeout nor update last_request_at by accessing skip_validate_session action" do
    Timecop.freeze Time.now
    get 'secret/index'

    Timecop.freeze 60.minutes.from_now
    get 'secret/not_validate_session'
    assert_response :success

    get 'secret/index'
    assert_redirected_to root_url

    Timecop.return
  end
end

# uninclude Module has not yet correctly implemented.
# Therefore, omit following test
#
# class TimeoutableDoNotValidateSessionInNotLoginAreaTest < ActionDispatch::IntegrationTest
#   def setup
# #     Goma.config.validate_session_even_in_not_login_area = false
# #     reinclude_timeout_module
#     @user = Fabricate(:user)
#     post 'session', username_or_email: @user.email, password: 'password'
#   end
# #
# #   def teardown
# #     Goma.config.validate_session_even_in_not_login_area = true
# #     reinclude_timeout_module
# #   end
#
#   test "should timeout if accessed a page which does not require login" do
#     Timecop.freeze Time.now
#     get 'secret/index'
#
#     Timecop.freeze 20.minutes.from_now
#     get '/'
#     assert_response :success
#
#     Timecop.freeze 20.minutes.from_now
#     get 'secret/index'
#     assert_redirected_to root_url
#
#     Timecop.return
#   end
#
#   test "should timeout if accessing skip_trackabled action" do
#     Timecop.freeze Time.now
#     get 'secret/index'
#
#     Timecop.freeze 20.minutes.from_now
#     get 'secret/not_track'
#     assert_response :success
#
#     Timecop.freeze 20.minutes.from_now
#     get 'secret/not_track'
#     assert_redirected_to root_url
#
#     Timecop.return
#   end
#
#   test "should not timeout but update last_request_at by accessing skip_timeout action" do
#     Timecop.freeze Time.now
#     get 'secret/index'
#
#     Timecop.freeze 60.minutes.from_now
#     get 'secret/not_timeout'
#     assert_response :success
#
#     Timecop.freeze 29.minutes.from_now
#     get 'secret/index'
#     assert_response :success
#
#     Timecop.freeze 60.minutes.from_now
#     get 'secret/not_timeout'
#     assert_response :success
#
#     Timecop.freeze 30.minutes.from_now
#     get 'secret/index'
#     assert_redirected_to root_url
#
#     Timecop.return
#   end
#
#   test "should not timeout nor update last_request_at by accessing skip_validate_session action" do
#     Timecop.freeze Time.now
#     get 'secret/index'
#
#     Timecop.freeze 60.minutes.from_now
#     get 'secret/not_validate_session'
#     assert_response :success
#
#     get 'secret/index'
#     assert_redirected_to root_url
#
#     Timecop.return
#   end
#
# private
#   def reinclude_timeout_module
#     ActionController::Base.send :uninclude, Goma::Controllers::Timeoutable
#     ActionController::Base.send :unextend, Goma::Controllers::Timeoutable::ClassMethods
#     # ActionController::Base.class_eval{ skip_filter :validate_session }
#     # SecretController.class_eval{ skip_filter :validate_session }
#     SecretController.class_eval do
#       _process_action_callbacks.reject! do |callback|
#         callback.filter == :validate_session ||
#           callback.filter == :skip_timeout ||
#           callback.filter == :skip_validate_session
#       end
#     end
#     load File.expand_path('../../../lib/goma/controllers/timeoutable.rb', __FILE__)
#     ActionController::Base.send :include,   Goma::Controllers::Timeoutable
#   end
# end
