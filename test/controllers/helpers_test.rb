require 'test_helper'

class HelpersTest < ActionController::TestCase
  tests ApplicationController

  setup do
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
  end

  test 'provide access to warden instance' do
    assert_equal @mock_warden, @controller.warden
  end

  test 'proxy scope_logged_in? to user' do
    @mock_warden.expects(:authenticate).with(scope: :user)
    @controller.user_logged_in?
  end
end
