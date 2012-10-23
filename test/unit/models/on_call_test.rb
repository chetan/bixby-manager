
require "test_helper"

class Bixby::Test::Models::OnCall < Bixby::Test::TestCase

  def setup
    super
    SimpleCov.command_name 'test:models:on_call'
  end

  def test_users
    o = FactoryGirl.build(:on_call)
    assert_nil o.next_user

    o.users = FactoryGirl.create_list(:user, 3).map{ |u| u.id }
    assert_kind_of Array, o.users

    n = o.next_user
    assert n
    assert_kind_of User, n
    assert_equal n.id, o.users.first.to_i

    o.save!

    o = OnCall.first
    assert_kind_of Array, o.users
    assert_equal 3, o.users.size
  end

end
