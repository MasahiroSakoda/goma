require 'test_helper'

class RecoverableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test 'should work reset password proccess' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')
    visit new_password_url
    fill_in :username_or_email, with: @user.email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      click_button 'Send me reset password instructions'
    end

    email = ActionMailer::Base.deliveries.last
    assert_match %r{/passwords/sesame/edit}, email.body.encoded

    visit edit_password_url('sesame')
    fill_in :user_password, with: 'newpassword'
    fill_in :user_password_confirmation, with: 'newpassword'
    click_button 'Change my password'
    assert_equal root_url, current_url
    assert_equal @user, _current_user

    @user.reload
    assert @user.valid_password?('newpassword')
  end

  test 'should execute validation check' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')
    visit new_password_url
    fill_in :username_or_email, with: @user.email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      click_button 'Send me reset password instructions'
    end

    mail = ActionMailer::Base.deliveries.last
    assert_match %r{/passwords/sesame/edit}, mail.body.encoded

    visit edit_password_url('sesame')
    fill_in :user_password, with: 'short'
    fill_in :user_password_confirmation, with: 'short'
    click_button 'Change my password'
    assert_nil _current_user
    @user.reload
    assert @user.valid_password?('password')

    fill_in :user_password, with: 'newpassword'
    fill_in :user_password_confirmation, with: 'newpassword'
    click_button 'Change my password'
    assert_equal root_url, current_url
    assert_equal @user, _current_user

    @user.reload
    assert @user.valid_password?('newpassword')
  end

  test 'should not accept wrong reset password token URL' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')
    visit new_password_url
    fill_in :username_or_email, with: @user.email
    click_button 'Send me reset password instructions'

    visit edit_password_url('beans')
    fill_in :user_password, with: 'newpassword'
    fill_in :user_password_confirmation, with: 'newpassword'
    click_button 'Change my password'

    assert_match /You can't change your password in this page without coming from a password reset email/, _flash[:alert]
    assert_match /Change my password/, page.body, 'should render "passwords/{token}/edit" template'

    @user.reload
    assert @user.valid_password?('password')
  end

  test 'should not accept expired reset password token URL' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')
    visit new_password_url
    fill_in :username_or_email, with: @user.email
    click_button 'Send me reset password instructions'

    Timecop.travel 7.hours.from_now
    visit edit_password_url('sesame')
    fill_in :user_password, with: 'newpassword'
    fill_in :user_password_confirmation, with: 'newpassword'
    click_button 'Change my password'

    assert_match /The password reset URL you visited has expired, please request a new one/, _flash[:alert]
    assert_match /Forget your password\?/, page.body, 'should render "passwords/new" template'

    @user.reload
    assert @user.valid_password?('password')
    Timecop.return
  end
end
