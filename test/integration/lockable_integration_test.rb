require 'test_helper'

class LockableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end


  test 'should work unlock process' do
    Goma.token_generator.stubs(:friendly_token).returns('sesame')
    @user.lock_access!
    assert @user.access_locked?

    email = ActionMailer::Base.deliveries.last
    assert_match %r{/unlocks/sesame}, email.body.encoded

    visit unlock_url('sesame')

    @user.reload
    assert_equal new_session_url, current_url
    refute @user.access_locked?
  end

  test 'should work resending unlock token process' do
    @user.lock_access!
    assert @user.access_locked?
    old_token = @user.unlock_token

    Goma.token_generator.stubs(:friendly_token).returns('sesame')

    visit new_unlock_url
    fill_in :username_or_email, with: @user.email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      click_button 'Resend unlock instructions'
    end
    email = ActionMailer::Base.deliveries.last
    assert_match %r{/unlocks/sesame}, email.body.encoded

    @user.reload
    refute_equal old_token, @user.unlock_token
    assert_equal new_session_url, current_url

    visit unlock_url('sesame')

    @user.reload
    assert_equal new_session_url, current_url
    refute @user.access_locked?
  end
end
