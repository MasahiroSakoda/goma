require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # This test might not be needed
  test 'should create user' do
    assert_difference 'User.count', 1 do
      post :create, {user: {username: 'foo', email: 'foo@example.com', password: 'password', password_confirmation: 'password'}}
    end
    assert_redirected_to new_session_url
    assert flash[:notice]
  end
end
