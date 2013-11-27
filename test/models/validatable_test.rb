require 'test_helper'

class ValidatableTest < ActiveSupport::TestCase
  def setup
    @user = Fabricate(:user, username: 'foo', email: 'foo@example.com')
  end

  test 'should pass all the validations with valid data' do
    assert_difference 'User.count', 1 do
      User.create!(username: 'bar', email: 'bar@example.com', password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_presence_of :username' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: nil, email: 'bar@example.com', password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_uniqueness_of :username' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'foo', email: 'bar@example.com', password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_presence_of :email' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'foo', email: nil, password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_uniqueness_of :email' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'bar', email: 'foo@example.com', password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_format_of :email' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'bar', email: 'bar.example.com', password: 'secret', password_confirmation: 'secret')
    end
  end

  test 'should validates_length_of :password with too short password' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'bar', email: 'bar@example.com', password: 's' * 5, password_confirmation: 's' * 5)
    end
  end

  test 'should validates_length_of :password with too long password' do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create!(username: 'bar', email: 'bar@example.com', password: 's' * 129, password_confirmation: 's' * 129)
    end

    assert_difference 'User.count', 1 do
      User.create!(username: 'baz', email: 'baz@example.com', password: 's' * 128, password_confirmation: 's' * 128)
    end
  end
end
