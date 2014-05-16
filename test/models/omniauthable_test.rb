require 'test_helper'

class OmniauthableTest < ActiveSupport::TestCase
  setup do
    @omniauth = {provider: 'development',
                 uid: 'foo'}
  end

  should "create user from omniauth" do
    User.any_instance.expects(:fill_with_omniauth).with(@omniauth)
    Authentication.any_instance.expects(:fill_with_omniauth).with(@omniauth)

    u = nil
    assert_difference ['User.count', 'Authentication.count'], 1 do
      u = User.create_with_omniauth!(@omniauth)
    end

    u.reload
    assert u
    assert u.activated?
    assert u.authentications.present?
  end

  should "not create user from omniauth when provider and uid are duplicated" do
    User.create_with_omniauth!(@omniauth)

    assert_raise ActiveRecord::RecordInvalid do
      User.create_with_omniauth!(@omniauth)
    end
  end

  should "have any number of authentications" do
    u = User.create_with_omniauth!(@omniauth)

    assert_difference 'Authentication.count', 2 do
      u.authentications << Authentication.build_with_omniauth({provider: 'developer', uid: 'bar'})
      u.authentications << Authentication.build_with_omniauth({provider: 'another-service', uid: 'foo'})
      u.save!
    end
  end
end
