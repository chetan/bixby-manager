require 'test_helper'

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase

  def test_create_tenant
    t = Bixby::User.new.create_tenant("foobar", "secret")
    assert t

    assert_throws(Bixby::API::Error) do
      t = Bixby::User.new.create_tenant("foobar", "secret")
    end

    t = Tenant.where(:name => "foobar").first
    assert !t.test_password("foobar")
    assert t.test_password("secret")
  end

  def test_create_user
    o = FactoryGirl.create(:org)
    u = Bixby::User.new.create_user(o.tenant.id, "John Doe", "jdoe", "secret", "jdoe@example.com")
    assert u

    assert_throws(Bixby::API::Error) do
      Bixby::User.new.create_user(o.tenant.id, "John Doe", "jdoe", "secret", "jdoe@example.com")
    end

    u = User.where(:username => "jdoe").first
    assert u
    refute u.phone
    assert SCrypt::Password.new(u.crypted_password) == "secret"
    assert_equal o, u.org
  end

end
