require 'test_helper'

class GomaTest < ActiveSupport::TestCase
  test "goma class method is introduced to ActiveRecord::Base" do
    assert ActiveRecord::Base.respond_to?(:goma)
    # assert User.respond_to?(:goma)

    # user = User.new
    # assert_equal "blahblah", user.blahblah
    # puts Goma.config.encryptor
  end

  test "should have module existence methods" do
    assert User.respond_to?(:password_authenticatable?)
    assert User.respond_to?(:confirmable?)
    assert User.respond_to?(:recoverable?)
    assert User.respond_to?(:timeoutable?)
    assert User.respond_to?(:trackable?)
    assert User.respond_to?(:omniauthable?)
    assert User.respond_to?(:lockable?)
  end
end
