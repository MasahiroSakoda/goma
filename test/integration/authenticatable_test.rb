require 'test_helper'

class AuthenticatableSessionTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test 'should login' do
    post 'session', username_or_email: @user.email, password: 'secret'
    assert_equal @user, request.env['warden'].user(:user)
  end

  test 'should redirect back correctly' do
    get 'secret/index'
    assert_redirected_to root_url
    post 'session', username_or_email: @user.email, password: 'secret'
    assert_redirected_to secret_index_url
  end
end
