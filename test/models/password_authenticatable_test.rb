require 'test_helper'

class PasswordAuthenticatableTest < ActiveSupport::TestCase
  def setup
    Fabricate(:user, username: 'foo', email: 'foo@example.com')
  end

  test 'should downcase case_insensitive_keys before validation' do
    user = Fabricate.build(:user, email: 'FOO@example.com')
    refute user.valid?
    assert_equal 'foo@example.com', user.email
  end

  test 'should strip whitespace strip_whitespace_keys before validation' do
    user = Fabricate.build(:user, email: '  foo@example.com  ')
    refute user.valid?
    assert_equal 'foo@example.com', user.email
  end

  test 'should not downcase non case_insensitive_keys before validation' do
    user = Fabricate.build(:user, username: 'FOO')
    assert user.valid?
    assert_equal 'FOO', user.username
  end

  test 'should not strip whitespace non strip_whitespace_keys before validation' do
    user = Fabricate.build(:user, username: '  foo  ')
    assert user.valid?
    assert_equal '  foo  ', user.username
  end
end
