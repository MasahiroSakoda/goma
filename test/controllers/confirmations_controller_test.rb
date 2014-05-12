require 'test_helper'

class ConfirmationsControllerTest < ActionController::TestCase
  test 'should activate user' do
    user = User.new(username: 'foo', email: 'foo@example.com', password: 'password', password_confirmation: 'password')
    user.save!

    get :activate, id: user.raw_confirmation_token
    assert_redirected_to new_session_url
    assert flash[:notice]
    user.reload
    assert user.activated?
  end
end