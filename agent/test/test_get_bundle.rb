
require 'helper'

module Bixby
class TestGetBundle < MiniTest::Unit::TestCase

  def setup
    @bundle_path = File.expand_path(File.dirname(__FILE__)) + "/support/test_bundle"
    h = { :repo => "local", :bundle => "system/provisioning", 'command' => "get_bundle.rb" }
    @c = CommandSpec.new(h)

    @manager_uri = "http://localhost:3000"
    @password = "foobar"
    @root_dir = "/tmp/agent_test_temp"
    @port = 9999
    `rm -rf #{@root_dir}`
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)

    ARGV.clear
  end

  def test_get_bundle

    assert @c.command_file
    assert File.exists? @c.command_file
    require @c.command_file

    Agent.stubs(:create).returns(@agent)

    # test our stub
    a = Agent.create
    assert_equal @agent, a

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })

    provisioner = Provision.new
    provisioner.stubs(:get_json_input).returns(cmd.to_json)

    # setup our expectations on the run method
    ret_list = JsonResponse.from_json('{"status":"success","message":null,"data":[{"file":"bin/echo","digest":"abcd"}],"code":null}')
    a.expects(:exec_api).once().returns(ret_list)
    a.expects(:exec_api_download).once().returns(true)
    `mkdir -p #{File.dirname(cmd.command_file)}`
    `touch #{cmd.command_file}`

    provisioner.run
  end

  def test_bad_json

    require @c.command_file

    Agent.stubs(:create).returns(@agent)

    # test our stub
    a = Agent.create
    assert_equal @agent, a

    provisioner = Provision.new
    provisioner.stubs(:get_json_input).returns(nil)

    assert_throws(SystemExit) do
      provisioner.run
    end

  end

end
end
