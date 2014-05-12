require 'test_helper'

class TrackableIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = Fabricate(:user)
  end

  test "should track" do
    assert_nil @user.last_login_at
    assert_nil @user.current_login_at
    assert_nil @user.last_login_ip
    assert_nil @user.current_login_ip
    assert_equal 0, @user.login_count

    Timecop.freeze 10.minutes.from_now
    @login_at = Time.now.utc
    post 'session', username_or_email: @user.email, password: 'password'

    Timecop.travel 10.minutes.from_now

    @user.reload
    assert_equal @login_at.to_s(:db), @user.last_login_at.to_s(:db)
    assert_equal @login_at.to_s(:db), @user.current_login_at.to_s(:db)
    assert_equal '127.0.0.1', @user.last_login_ip
    assert_equal '127.0.0.1', @user.current_login_ip
    assert_equal 1, @user.login_count

    get 'secret/index'

    Timecop.travel 10.minutes.from_now

    @user.reload
    assert_equal @login_at.to_s(:db), @user.last_login_at.to_s(:db)
    assert_equal @login_at.to_s(:db), @user.current_login_at.to_s(:db)
    assert_equal '127.0.0.1', @user.last_login_ip
    assert_equal '127.0.0.1', @user.current_login_ip
    assert_equal 1, @user.login_count

    delete 'session'

    Timecop.freeze 10.minutes.from_now
    @second_login_at = Time.now.utc
    post 'session', {username_or_email: @user.email, password: 'password'}, {'REMOTE_ADDR' => '192.168.1.10'}

    Timecop.travel 10.minutes.from_now

    @user.reload
    assert_equal @login_at.to_s(:db), @user.last_login_at.to_s(:db)
    assert_equal @second_login_at.to_s(:db), @user.current_login_at.to_s(:db)
    assert_equal '127.0.0.1', @user.last_login_ip
    assert_equal '192.168.1.10', @user.current_login_ip
    assert_equal 2, @user.login_count

    Timecop.return
  end
end
