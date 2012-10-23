
require "test_helper"

class Bixby::Test::Models::Command < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:models:command'
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_path
    cmd = FactoryGirl.create(:command)
    assert cmd
    assert cmd.path =~ %r{repo/foo/bin/bar$}
  end

end
