require 'test_helper'

class PasswordAuthenticatableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test 'should login' do
    visit new_session_url
    fill_in :username_or_email, with: @user.email
    fill_in :password, with: 'password'
    click_button 'Login'
    assert_equal root_url, current_url
    assert_equal @user, _current_user
  end

  test 'should redirect back' do
    visit secret_url
    assert_equal root_url, current_url

    visit new_session_url
    fill_in :username_or_email, with: @user.email
    fill_in :password, with: 'password'
    click_button 'Login'
    assert_equal secret_url, current_url
    assert_equal @user, _current_user
  end

  test 'should redirect back to url with parameters' do
    visit secret_url(page: 100)
    assert_equal root_url, current_url

    visit new_session_url
    fill_in :username_or_email, with: @user.email
    fill_in :password, with: 'password'
    click_button 'Login'
    assert_equal secret_url(page: 100), current_url
    assert_equal @user, _current_user
  end
end
