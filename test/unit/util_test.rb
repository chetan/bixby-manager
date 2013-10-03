
require 'helper'

class Bixby::Test::Util < Bixby::Test::TestCase

  def test_const_exists?
    assert Bixby::Util.const_exists? "Object"
    assert Bixby::Util.const_exists? "BIXBY_CONFIG"
    assert Bixby::Util.const_exists? "Bixby::Test"
    refute Bixby::Util.const_exists? "BIXBY_FOO"
  end

  def test_create_const_map
    assert Metric::Status::CONST_MAP
    assert_equal 3, Metric::Status.lookup("CRITICAL")
    assert_equal 3, Metric::Status.lookup(:CRITICAL)
    assert_equal "WARNING", Metric::Status.lookup(2)
  end

end

