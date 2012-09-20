
require 'test_helper'

class Bixby::Test::Util < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:util'
  end

  def test_const_exists?
    assert const_exists? "Object"
    assert const_exists? "BIXBY_CONFIG"
    assert const_exists? "Bixby::Test"
    refute const_exists? "BIXBY_FOO"
  end

end

