require 'test_helper'

class RememberableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test 'should not remember when remember_me is not set' do
    post 'session', username_or_email: @user.email, password: 'password'
    assert @user, request.env['warden'].user(:user)

    Timecop.freeze 30.minutes.from_now
    get 'secret/index'
    assert_redirected_to root_url

    Timecop.return
  end

  test 'should remember' do
    swap ApplicationController, allow_forgery_protection: true do
      get 'session/new'
      post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']

      @user.reload
      assert @user, request.env['warden'].user(:user)
      assert cookies['remember_user_token']
      assert_equal @user.serialize_into_cookie, signed_cookie('remember_user_token')

      Timecop.freeze 30.minutes.from_now
      get 'secret/index'
      assert_response :success

      Timecop.return
    end
  end

  test 'should not remember without authenticity_token' do
    swap ApplicationController, allow_forgery_protection: true do
      get 'session/new'
      assert_raise ActionController::InvalidAuthenticityToken do
        post 'session', username_or_email: @user.email, password: 'password', remember_me: '1'
      end

      refute request.env['warden'].user(:user)
      refute cookies['remember_user_token']
      refute signed_cookie('remember_user_token')
    end
  end

  test 'should not remember with wrong authenticity_token' do
    swap ApplicationController, allow_forgery_protection: true do
      get 'session/new'
      assert_raise ActionController::InvalidAuthenticityToken do
        post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: 'wrong'
      end

      refute request.env['warden'].user(:user)
      refute cookies['remember_user_token']
      refute signed_cookie('remember_user_token')
    end
  end

  test 'should login with remember cookie' do
    swap ApplicationController, allow_forgery_protection: true do
      get 'session/new'
      post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']

      reset!

      get 'secret/index'
      assert_redirected_to root_url

      @user.reload
      update_signed_cookies(remember_user_token: @user.serialize_into_cookie)

      get 'secret/index'
      assert_response :success
    end
  end

  test  'should forget when logout' do
    swap ApplicationController, allow_forgery_protection: true do
      get 'session/new'
      post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']
      assert @user, request.env['warden'].user(:user)

      delete 'session', authenticity_token: session['_csrf_token']
      refute request.env['warden'].user(:user)

      get 'secret/index'
      assert_redirected_to root_url
      refute request.env['warden'].user(:user)
    end
  end

  test 'should exist remember view element' do
    visit new_session_url
    fill_in :username_or_email, with: @user.email
    fill_in :password, with: 'password'
    check :remember_me
    click_button 'Login'

    @user.reload
    assert_equal root_url, current_url
    assert_equal @user, _current_user
    assert _cookies['remember_user_token']
    assert_equal @user.serialize_into_cookie, _signed_cookie('remember_user_token')
  end
end
