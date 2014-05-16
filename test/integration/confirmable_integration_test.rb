require 'test_helper'

class ConfirmableIntegrationTest < ActionDispatch::IntegrationTest
  test 'should work activation proccess' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')

    visit new_user_url
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'user@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'

    assert_difference ['User.count', 'ActionMailer::Base.deliveries.size'], 1 do
      click_button 'Sign up'
    end
    user = User.order(created_at: :desc).first
    refute user.activated?

    email = ActionMailer::Base.deliveries.last
    assert_match %r{/confirmations/sesame}, email.body.encoded

    visit confirmation_url('sesame')
    assert_equal 'Your account was successfully activated.', _flash[:notice]
    assert_equal new_session_url, current_url
    user.reload
    assert user.activated?
  end

  test 'should be able to change email and resend activation token before activation with username and password which is entered in registration' do
    Goma.token_generator.expects(:friendly_token).twice.returns('sesame', 'simsim')

    visit new_user_url
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'wrong@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_button 'Sign up'

    user = User.order(created_at: :desc).first
    refute user.activated?


    visit new_user_url
    assert_match /If you signed up with wrong email address/, page.body
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'correct@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'

    assert_no_difference 'User.count' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        click_button 'Sign up'
      end
    end

    email = ActionMailer::Base.deliveries.last
    assert_match %r{/confirmations/simsim}, email.body.encoded
    assert_equal 'correct@example.com', email.to.first

    visit confirmation_url('simsim')
    assert_equal 'Your account was successfully activated.', _flash[:notice]
    assert_equal new_session_url, current_url
    user.reload
    assert user.activated?
  end

  test 'should not activate user with wrong token' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')

    visit new_user_url
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'user@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_button 'Sign up'

    user = User.order(created_at: :desc).first
    refute user.activated?

    visit confirmation_url('beans')
    assert_equal confirmation_url('beans'), current_url
    assert_match /Not found any account by this URL/, _flash[:alert]
    user.reload
    refute user.activated?
  end

  test 'should resend activation token by username' do
    Goma.token_generator.expects(:friendly_token).twice.returns('sesame', 'simsim')

    visit new_user_url
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'user@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_button 'Sign up'

    user = User.order(created_at: :desc).first
    refute user.activated?

    visit new_confirmation_url
    fill_in :username_or_email, with: 'user'

    assert_no_difference 'User.count' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        click_button 'Resend activation instructions'
      end
    end
    email = ActionMailer::Base.deliveries.last
    assert_match %r{/confirmations/simsim}, email.body.encoded

    visit confirmation_url('simsim')
    assert_equal 'Your account was successfully activated.', _flash[:notice]
    assert_equal new_session_url, current_url
    user.reload
    assert user.activated?
  end

  test 'should resend activation token by email' do
    Goma.token_generator.expects(:friendly_token).twice.returns('sesame', 'simsim')

    visit new_user_url
    fill_in :user_username, with: 'user'
    fill_in :user_email, with: 'user@example.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_button 'Sign up'

    user = User.order(created_at: :desc).first
    refute user.activated?

    visit new_confirmation_url
    fill_in :username_or_email, with: 'user@example.com'

    assert_no_difference 'User.count' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        click_button 'Resend activation instructions'
      end
    end
    email = ActionMailer::Base.deliveries.last
    assert_match %r{/confirmations/simsim}, email.body.encoded

    visit confirmation_url('simsim')
    assert_equal 'Your account was successfully activated.', _flash[:notice]
    assert_equal new_session_url, current_url
    user.reload
    assert user.activated?
  end

  test 'should work email confirmation process' do
    user = Fabricate(:user, email: 'old@example.com')

    Goma.token_generator.stubs(:friendly_token).returns('sesame')

    visit new_session_url
    fill_in :username_or_email, with: 'old@example.com'
    fill_in :password, with: 'password'
    click_button 'Login'

    visit edit_user_url(user)
    fill_in :user_email, with: 'new@example.com'

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      click_button 'Update'
    end

    email = ActionMailer::Base.deliveries.last
    assert_match %r{/confirmations/sesame/email}, email.body.encoded

    user.reload
    assert_equal 'old@example.com', user.email
    assert_equal 'new@example.com', user.unconfirmed_email

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      visit email_confirmation_url('sesame')
    end
    email = ActionMailer::Base.deliveries.last
    assert_match /You have successfully changed your account email/, email.body.encoded

    user.reload
    assert_equal root_url, current_url
    assert_equal 'new@example.com', user.email
    assert_nil user.unconfirmed_email
  end
end
