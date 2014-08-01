
require "helper"

class Bixby::Test::Models::User < Bixby::Test::TestCase

  def test_crypted_pw
    user = FactoryGirl.create(:user)
    assert user
    assert user.encrypted_password
    assert user.valid_password?("foobar123")
  end

end
