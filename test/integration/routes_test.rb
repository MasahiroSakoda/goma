require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user, password: 'password')
  end

  test 'constraints user_logged_in? should work correctly' do
    get 'a_page'
    assert_response 200
    assert_instance_of HomeController, @controller
    assert_equal 'a_page_for_visitors', @controller.action_name
    post 'session', username_or_email: @user.email, password: 'password'
    get 'a_page'
    assert_response 200
    assert_instance_of HomeController, @controller
    assert_equal 'a_page_for_users', @controller.action_name
  end

  test 'constraints current_user{|u|... should work correctly' do
    post 'session', username_or_email: @user.email, password: 'password'

    assert_raise ActionController::RoutingError do
      get 'a_path_constraints_current_user_with_arity_block'
    end

    @user.created_at = 2.years.ago
    @user.save!
    get 'a_path_constraints_current_user_with_arity_block'
    assert_response 200
    assert_instance_of SecretController, @controller
    assert_equal 'an_action_constraints_current_user_with_arity_block', @controller.action_name
  end

  test 'constraints current_user{... should work correctly' do
    post 'session', username_or_email: @user.email, password: 'password'

    assert_raise ActionController::RoutingError do
      get 'a_path_constraints_current_user_with_no_arity_block'
    end

    @user.created_at = 2.years.ago
    @user.save!
    get 'a_path_constraints_current_user_with_no_arity_block'
    assert_response 200
    assert_instance_of SecretController, @controller
    assert_equal 'an_action_constraints_current_user_with_no_arity_block', @controller.action_name
  end

  context 'Remembered user' do
    setup do
      @user.created_at = 2.years.ago
      @user.save!
    end

    should 'work correctly with constraints user_logged_in?' do
      swap ApplicationController, allow_forgery_protection: true do
        get 'session/new'
        post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']
        reset!

        get 'a_page'
        assert_response 200
        assert_instance_of HomeController, @controller
        assert_equal 'a_page_for_visitors', @controller.action_name

        @user.reload
        update_signed_cookies(remember_user_token: @user.serialize_into_cookie)

        get 'a_page'
        assert_response 200
        assert_instance_of HomeController, @controller
        assert_equal 'a_page_for_users', @controller.action_name
      end
    end

    should 'work correctly constraints current_user{|u|...' do
      swap ApplicationController, allow_forgery_protection: true do
        assert_raise ActionController::RoutingError do
          get 'a_path_constraints_current_user_with_arity_block'
        end

        get 'session/new'
        post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']
        reset!

        @user.reload
        update_signed_cookies(remember_user_token: @user.serialize_into_cookie)

        get 'a_path_constraints_current_user_with_arity_block'
        assert_response 200
        assert_instance_of SecretController, @controller
        assert_equal 'an_action_constraints_current_user_with_arity_block', @controller.action_name
      end
    end

    should 'work correctly constraints current_user{...' do
      swap ApplicationController, allow_forgery_protection: true do
        assert_raise ActionController::RoutingError do
          get 'a_path_constraints_current_user_with_no_arity_block'
        end

        get 'session/new'
        post 'session', username_or_email: @user.email, password: 'password', remember_me: '1', authenticity_token: session['_csrf_token']
        reset!

        @user.reload
        update_signed_cookies(remember_user_token: @user.serialize_into_cookie)

        get 'a_path_constraints_current_user_with_no_arity_block'
        assert_response 200
        assert_instance_of SecretController, @controller
        assert_equal 'an_action_constraints_current_user_with_no_arity_block', @controller.action_name
      end
    end
  end
end
