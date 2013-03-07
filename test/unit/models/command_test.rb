
require "test_helper"

class Bixby::Test::Models::Command < Bixby::Test::TestCase

  def test_path
    cmd = FactoryGirl.create(:command)
    assert cmd
    assert cmd.path =~ %r{vendor/test_bundle/bin/cat$}
  end

end
