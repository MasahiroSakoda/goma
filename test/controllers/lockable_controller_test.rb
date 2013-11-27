require 'test_helper'

class LockableControllerTest < ActionController::TestCase
  tests SessionsController

  setup do
    User.goma_config.maximum_attempts = 5
    @user = Fabricate(:user)
  end

  teardown do
    User.goma_config.maximum_attempts = 20
  end

  should 'be reset failed_attempts when user logs in successfully' do
    assert_equal 0, @user.failed_attempts
    2.times{ post :create, {username_or_email: @user.email, password: 'wrong'} }
    assert_equal 2, @user.reload.failed_attempts

    post :create, {username_or_email: @user.email, password: 'secret'}
    assert_equal 0, @user.reload.failed_attempts
  end

  context 'When config.unlock_strategies == [:email], user' do
    setup do
      User.goma_config.unlock_strategies = [:email]
    end

    teardown do
      User.goma_config.unlock_strategies = [:email, :time]
    end

    should 'be locked when number of login attemps exceeds config.maximum_attempts' do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        5.times do
          post :create, {username_or_email: @user.email, password: 'wrong'}
        end
      end
      refute @user.reload.access_locked?

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        post :create, {username_or_email: @user.email, password: 'wrong'}
      end
      assert @user.reload.access_locked?
    end


    should 'not be unlocked after config.unlock_in time' do
      6.times do
        post :create, {username_or_email: @user.email, password: 'wrong'}
      end
      assert @user.reload.access_locked?

      Timecop.freeze(1.hour.from_now) do
        assert @user.reload.access_locked?
      end
    end
  end


  context 'When config.unlock_strategies == [:time], user' do
    setup do
      User.goma_config.unlock_strategies = [:time]
    end

    teardown do
      User.goma_config.unlock_strategies = [:email, :time]
    end

    should 'be locked without sending email' do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        5.times do
          post :create, {username_or_email: @user.email, password: 'wrong'}
        end
      end
      refute @user.reload.access_locked?

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        post :create, {username_or_email: @user.email, password: 'wrong'}
      end
      assert @user.reload.access_locked?
    end

    should 'be unlocked after config.unlock_in time' do
      6.times do
        post :create, {username_or_email: @user.email, password: 'wrong'}
      end
      assert @user.reload.access_locked?

      Timecop.freeze(1.hour.from_now) do
        refute @user.reload.access_locked?
      end
    end
  end
end

