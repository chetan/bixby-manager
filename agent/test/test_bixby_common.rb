require 'helper'

module Bixby
class TestDevopsAgent < MiniTest::Unit::TestCase

  def test_common_loaded
    assert_equal(JsonRequest, JsonRequest.new(nil, nil).class)
    assert_equal(BundleNotFound, BundleNotFound.new.class)
    assert_equal(CommandNotFound, CommandNotFound.new.class)
    assert_equal(CommandSpec, CommandSpec.new.class)
  end

end
end
