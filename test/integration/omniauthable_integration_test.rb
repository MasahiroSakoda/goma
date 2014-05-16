require 'test_helper'

class OmniauthableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new({
      provider: 'developer',
      uid:      '1234567'
    })
  end

  test 'should create user with omniauth' do
    visit new_session_url

    assert_difference ['User.count', 'Authentication.count'], 1 do
      click_link 'Sign in with Developer'
    end

    assert_equal root_url, current_url, 'should be redirected to root_url'
    assert_equal 'Successfully authenticated from developer account.', _flash[:notice]

    assert _current_user
    assert_equal 'developer', _current_user.authentications.first.provider
    assert_equal '1234567', _current_user.authentications.first.uid
  end

  test 'should redirect back after creating user with omniauth ' do
    visit secret_url
    assert_equal root_url, current_url, 'should be redirect to root_url'

    visit new_session_url
    click_link 'Sign in with Developer'

    assert_equal secret_url, current_url, 'should redirect back'
    assert_equal 'Successfully authenticated from developer account.', _flash[:notice]
  end

  test 'should authenticate but not create user if already created' do
    visit new_session_url
    click_link 'Sign in with Developer'
    _warden.logout(:user)


    visit new_session_url

    assert_no_difference ['User.count', 'Authentication.count'] do
      click_link 'Sign in with Developer'
    end

    assert_equal root_url, current_url, 'should be redirected to root_url'
    assert_equal 'Successfully authenticated from developer account.', _flash[:notice]

    assert _current_user
    assert_equal 'developer', _current_user.authentications.first.provider
    assert_equal '1234567', _current_user.authentications.first.uid
  end


  test 'should handle errors' do
    OmniAuth.config.mock_auth[:developer] = :access_denied

    visit new_session_url

    assert_no_difference ['User.count', 'Authentication.count'] do
      click_link 'Sign in with Developer'
    end

    assert_match /Could not authenticate you from Developer because "Access denied"/, _flash[:alert]
    assert_equal new_session_url, current_url
  end

  test 'should not accept unknown provider' do
    assert_no_difference ['User.count', 'Authentication.count'] do
      assert_raise ActionController::RoutingError do
        visit 'auth/unknown'
      end
    end
  end
end
