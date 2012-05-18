
require 'test_helper'

class TestJSONColumn < ActiveSupport::TestCase

  def test_dump_and_load
    c = FactoryGirl.create(:command)
    c.options = { :foo => "bar", "baz" => 32 }
    c.save!
    assert c.id

    c = Command.find(c.id)
    assert c

    opts = c.options
    assert opts
    assert_kind_of Hash, opts
    assert opts.include? "foo"
    assert_equal "bar", opts["foo"]
  end

end
