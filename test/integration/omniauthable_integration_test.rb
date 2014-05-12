require 'test_helper'

class OmniauthableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: 'twitter',
      uid:      '1234567'
    })
  end

  test 'should create user with omniauth' do
    get '/auth/twitter'
    assert_redirected_to '/auth/twitter/callback'

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      assert_difference ['User.count', 'Authentication.count'], 1 do
        follow_redirect!
      end
    end
    assert_redirected_to root_url

    assert current_user
    assert_equal 'twitter', current_user.authentications.first.provider
    assert_equal '1234567', current_user.authentications.first.uid
  end
end
