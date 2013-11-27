require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @user = Fabricate(:user)
  end

  test 'should login with email' do
    post :create, {username_or_email: @user.email, password: 'secret'}
    assert_redirected_to root_url
    assert flash[:notice]
    assert_equal @user, current_user
  end

  test 'should login with username' do
    post :create, {username_or_email: @user.username, password: 'secret'}
    assert_redirected_to root_url
    assert flash[:notice]
    assert_equal @user, current_user
  end

  test 'should not login with incorrect password' do
    post :create, {username_or_email: @user.email, password: 'wrong'}
    assert_nil current_user
    assert_response :success
    assert_template :new
    assert flash[:alert]
  end

  test 'should login with case-insensitive key case-insensitively' do
    assert :email.in? @user.goma_config.case_insensitive_keys
    post :create, {username_or_email: @user.email.upcase, password: 'secret'}
    assert_redirected_to root_url
    assert flash[:notice]
    assert_equal @user, current_user
  end

  test 'should login with strip-whitespace key whitespace-strippingly' do
    assert :email.in? @user.goma_config.strip_whitespace_keys
    post :create, {username_or_email: " " + @user.email + '  ', password: 'secret'}
    assert_redirected_to root_url
    assert flash[:notice]
    assert_equal @user, current_user
  end

  test 'should not login with non case-insensitive key case-insensitively' do
    refute :username.in? @user.goma_config.case_insensitive_keys
    post :create, {username_or_email: @user.username.upcase, password: 'secret'}
    assert_nil current_user
    assert_response :success
    assert_template :new
    assert flash[:alert]
  end

  test 'should not login with non strip-whitespace key whitespace-strippingly' do
    refute :username.in? @user.goma_config.strip_whitespace_keys
    post :create, {username_or_email: " " + @user.username + '  ', password: 'secret'}
    assert_nil current_user
    assert_response :success
    assert_template :new
    assert flash[:alert]
  end

  test 'should raise exception when login! with incorrect password' do
    assert_raise Goma::InvalidIdOrPassword do
      @controller.login!(@user.email, 'wrong')
    end
  end

  test 'should logout' do
    force_login(@user)
    assert_equal @user, current_user

    delete :destroy
    assert_redirected_to root_url
    assert_nil current_user
  end
end
