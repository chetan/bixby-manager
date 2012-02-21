
require 'helper'

class TestBundleCommand < MiniTest::Unit::TestCase

  def setup
    @manager_uri = "http://localhost:3000"
    @password = "foobar"
    @root_dir = "/tmp/agent_test_temp"
    @port = 9999
    `rm -rf #{@root_dir}`
    ENV["DEVOPS_ROOT"] = @root_dir
    setup_existing_agent()

    ARGV.clear
  end

  def setup_existing_agent
    src = File.expand_path(File.join(File.dirname(__FILE__), "support/root_dir"))
    dest = File.join(@root_dir, "etc")
    FileUtils.mkdir_p(dest)
    FileUtils.copy_entry(src, dest)
  end

  def test_subclasses
    assert BundleCommand.subclasses
    assert (not BundleCommand.subclasses.empty?)
    assert BundleCommand.subclasses.include? Foobar

    assert Foobar.subclasses
    assert Foobar.subclasses.include? Baz
  end

  # shouldn't throw an errors w/ no input
  def test_read_stdin
    input = BundleCommand.new.read_stdin()
    assert_equal "", input
  end

  def test_get_json_input
    json = BundleCommand.new.get_json_input()
    assert json
    assert_equal(Hash, json.class)
    assert_equal({}, json)
  end

end

class Foobar < BundleCommand
end

class Baz < Foobar
end
