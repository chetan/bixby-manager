
require 'helper'

class TestApp < MiniTest::Unit::TestCase

  def setup
    WebMock.reset!

    @manager_uri = "http://localhost:3000"
    @password = "foobar"
    @root_dir = "/tmp/agent_test_temp"
    @port = 9999
    `rm -rf #{@root_dir}`
  end

  def test_load_agent
    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir
    ARGV << @manager_uri

    stub_request(:post, "http://localhost:3000/api").to_return(:status => 200, :body => "{}")

    app = App.new
    app.load_agent()

    assert_requested(:post, @manager_uri + "/api", :times => 1)
    assert( File.exists? File.join(@root_dir, "etc", "devops.yml") )
  end

  def test_missing_manager_uri
    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir

    app = App.new
    assert_throws(SystemExit) do
      app.load_agent()
    end
  end

  def test_register_failed

    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir
    ARGV << @manager_uri

    stub_request(:post, "http://localhost:3000/api").to_return(:status => 200, :body => {:status => "fail"}.to_json)

    app = App.new
    assert_throws(SystemExit) do
      app.load_agent()
    end

  end

  def test_setup_logger
    ARGV.clear
    ARGV << "--debug"
    App.new.setup_logger
    assert_equal 0, Logging::Logger.root.level

    ARGV.clear
    App.new.setup_logger
    assert_equal 2, Logging::Logger.root.level
  end

end
