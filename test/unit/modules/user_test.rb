require 'helper'

class Bixby::Test::Modules::User < Bixby::Test::TestCase

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
    u = Bixby::User.new.create_user(o.tenant.id, "John Doe", "jdoe", "secret123", "jdoe@example.com")
    assert u

    assert_throws(Bixby::API::Error) do
      Bixby::User.new.create_user(o.tenant.id, "John Doe", "jdoe", "secret123", "jdoe@example.com")
    end

    u = User.where(:username => "jdoe").first
    assert u
    refute u.phone
    assert Devise::Encryptable::Encryptors::Scrypt.compare(
      u.encrypted_password, "secret123", nil, u.password_salt, Devise.pepper)
    assert_equal o, u.org
  end

end
