require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # This test might not be needed
  test 'should create user' do
    assert_difference 'User.count', 1 do
      post :create, {user: {username: 'foo', email: 'foo@example.com', password: 'password', password_confirmation: 'password'}}
    end
    assert_redirected_to root_url
    assert flash[:notice]
  end

  test 'should activate user' do
    user = User.new(username: 'foo', email: 'foo@example.com', password: 'password', password_confirmation: 'password')
    user.save!

    get :activate, id: user.raw_confirmation_token
    assert_redirected_to root_url
    assert flash[:notice]
    user.reload
    assert user.activated?
  end
end
