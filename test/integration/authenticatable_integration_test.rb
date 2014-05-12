require 'test_helper'

class AuthenticatableSessionIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test 'should login' do
    post 'session', username_or_email: @user.email, password: 'password'
    assert_equal @user, request.env['warden'].user(:user)
  end

  test 'should redirect back correctly' do
    get 'secret/index'
    assert_redirected_to root_url
    post 'session', username_or_email: @user.email, password: 'password'
    assert_redirected_to secret_index_url
  end

  test 'should redirect back url with parameters correctly' do
    get 'secret/index?page=100'
    assert_redirected_to root_url
    post 'session', username_or_email: @user.email, password: 'password'
    assert_redirected_to '/secret/index?page=100'
  end
end
