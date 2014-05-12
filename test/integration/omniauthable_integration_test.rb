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
    follow_redirect!
    assert_redirected_to root_url
  end
end
