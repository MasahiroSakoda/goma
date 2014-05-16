require "test_helper"

class ConfirmableTest < ActiveSupport::TestCase
  context "A newly created user" do
    setup do
      @user = User.new(username: 'foo', email: 'foo@example.com', password: 'password')
    end

    should "not be activated" do
      @user.save!
      @user.reload
      refute @user.activated?
    end

    should "be sent activation needed email when saving" do
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        @user.save!
      end
    end
  end

  context "User.load_from_activation_token!" do
    setup do
      @user = Fabricate(:unactivated_user)
    end

    should "load user record with correct activation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user = User.load_from_activation_token!(raw_token)
      assert_equal @user, loaded_user
    end

    should "raise exception with incorrect activation token" do
      assert_raise Goma::NotFound do
        User.load_from_activation_token!('blahblahblah')
      end
    end

    should "raise exception with correct activation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      assert_raise Goma::TokenExpired do
        User.load_from_activation_token!(raw_token)
      end
    end
  end

  context "User.load_from_activation_token_with_error" do
    setup do
      @user = Fabricate(:unactivated_user)
    end

    should "return user record and nil with correct activation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user, error = User.load_from_activation_token_with_error(raw_token)
      assert_equal @user, loaded_user
      assert_nil error
    end

    should "return nil and :not_found with incorrect activation token" do
      loaded_user, error = User.load_from_activation_token_with_error('blahblahblah')
      assert_nil loaded_user
      assert_equal :not_found, error
    end

    should "return nil and :token_expired with correct activation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      loaded_user, error = User.load_from_activation_token_with_error(raw_token)
      assert_nil loaded_user
      assert_equal :token_expired, error
    end
  end

  context "User.load_from_activation_token" do
    setup do
      @user = Fabricate(:unactivated_user)
    end

    should "return user record with correct activation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user = User.load_from_activation_token(raw_token)
      assert_equal @user, loaded_user
    end

    should "return nil with incorrect activation token" do
      loaded_user = User.load_from_activation_token('blahblahblah')
      assert_nil loaded_user
    end

    should "return nil with correct activation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      loaded_user = User.load_from_activation_token(raw_token)
      assert_nil loaded_user
    end
  end

  context "A user" do
    setup do
      @user = Fabricate(:unactivated_user)
    end

    should "be filled activated_at field when activate!ing" do
      refute @user.activated_at
      @user.activate!
      @user.reload
      assert @user.activated_at
    end

    should "be sent activation success email when activate!ing" do
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        @user.activate!
      end
    end
  end

  context "A user who changed email" do
    setup do
      @user = Fabricate(:user)
      @old_email = @user.email
      @user.email = 'another@example.com'
    end

    should "be postponed email change" do
      @user.save!
      assert_equal @old_email, @user.email
      assert_equal 'another@example.com', @user.unconfirmed_email
    end

    should "be sent email confirmation needed email when saving" do
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        @user.save!
      end
    end
  end

  context "User.load_from_email_confirmation_token!" do
    setup do
      @user = Fabricate(:user)
      @user.email = 'another@example.com'
      @user.save!
    end

    should "find user record with correct email confirmation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user = User.load_from_email_confirmation_token!(raw_token)
      assert_equal @user, loaded_user
    end

    should "not find user record with incorrect confirmation token" do
      assert_raise Goma::NotFound do
        User.load_from_email_confirmation_token!('blahblahblah')
      end
    end

    should "not find user record with correct confirmation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      assert_raise Goma::TokenExpired do
        User.load_from_email_confirmation_token!(raw_token)
      end
    end
  end

  context "User.load_from_email_confirmation_token_with_error" do
    setup do
      @user = Fabricate(:user)
      @user.email = 'another@example.com'
      @user.save!
    end

    should "return user record and nil with correct email_confirmation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user, error = User.load_from_email_confirmation_token_with_error(raw_token)
      assert_equal @user, loaded_user
      assert_nil error
    end

    should "return nil and :not_found with incorrect email_confirmation token" do
      loaded_user, error = User.load_from_email_confirmation_token_with_error('blahblahblah')
      assert_nil loaded_user
      assert_equal :not_found, error
    end

    should "return nil and :token_expired with correct email_confirmation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      loaded_user, error = User.load_from_email_confirmation_token_with_error(raw_token)
      assert_nil loaded_user
      assert_equal :token_expired, error
    end
  end

  context "User.load_from_email_confirmation_token" do
    setup do
      @user = Fabricate(:user)
      @user.email = 'another@example.com'
      @user.save!
    end

    should "return user record with correct email_confirmation token" do
      raw_token = @user.raw_confirmation_token
      loaded_user = User.load_from_email_confirmation_token(raw_token)
      assert_equal @user, loaded_user
    end

    should "return nil with incorrect email_confirmation token" do
      loaded_user = User.load_from_email_confirmation_token('blahblahblah')
      assert_nil loaded_user
    end

    should "return nil with correct email_confirmation token which is expired" do
      raw_token = @user.raw_confirmation_token
      @user.update_attribute(:confirmation_token_sent_at, 7.days.ago)

      loaded_user = User.load_from_email_confirmation_token(raw_token)
      assert_nil loaded_user
    end
  end

end
