
require 'helper'

module Bixby
class Test::Modules::RemoteExec < Bixby::Test::TestCase

  def setup
    super
    ENV["BIXBY_HOME"] = File.join(Rails.root, "test", "support", "root_dir")
    Bixby.instance_eval{ @client = nil }

    @repo = FactoryGirl.create(:repo)
    @bundle = Bundle.new(:path => "test_bundle", :repo => @repo)
    @bundle.save
    @bundle2 = Bundle.new(:path => "system/provisioning", :repo => @repo)
    @bundle2.save
    @agent = FactoryGirl.create(:agent)
  end

  def test_create_spec
      c = CommandSpec.new(:repo => "support", :bundle => "foobar")
      assert_equal c, Bixby::RemoteExec.new.create_spec(c)

      c = CommandSpec.new(:repo => "support", :bundle => "foobar")
      s = Bixby::RemoteExec.new.create_spec(c.to_json)
      assert_equal c.repo, s.repo
      assert_equal c.bundle, s.bundle

      cmd = Command.new(:bundle => @bundle, :command => "cat", :repo => @repo)
      cs = Bixby::RemoteExec.new.create_spec(cmd)

      assert_not_equal cs, cmd
      assert_equal "cat", cs.command
      assert_equal "test_bundle", cs.bundle
      assert cs.command_exists?
      assert cs.digest

      assert_equal "cat", cs.user
      assert_equal "feline", cs.group

      cmd.save!
      cs = Bixby::RemoteExec.new.create_spec(cmd.id)
      assert_equal "cat", cs.command
      assert_equal "test_bundle", cs.bundle
  end

  def test_exec
    cmd = Command.new(:bundle => @bundle, :command => "baz", :repo => @repo)
    cmd.save

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "shell_exec" and jp["repo"] == "vendor" and jp["bundle"] == "test_bundle" and jp["command"] == "baz"
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json)

    ret = Bixby::RemoteExec.new.exec(@agent, cmd)

    assert_requested(stub)
    assert ret.success?
  end

  def test_exec_is_logged
    cmd = Command.new(:bundle => @bundle, :command => "baz", :repo => @repo)
    cmd.save

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "shell_exec" and jp["repo"] == "vendor" and jp["bundle"] == "test_bundle" and jp["command"] == "baz"
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json)

    ret = Bixby::RemoteExec.new.exec(@agent, cmd)

    assert_requested(stub)
    assert ret.success?

    log = CommandLog.first
    assert log
    assert_equal @agent.host.org.id, log.org_id
    assert_equal @agent.id, log.agent_id
    assert_equal cmd.id, log.command_id
    assert log.org
    assert log.agent
    assert log.command
    assert_nil log.args

    assert_equal true, log.exec_status
    assert_nil log.exec_code

    assert_equal 0, log.status
    assert_equal "frobnicator echoed", log.stdout
    assert_nil log.stderr

    assert log.requested_at
    assert log.time_taken > 0
  end

  def test_exec_with_provision
    cmd = Command.new(:bundle => @bundle, :command => "echo", :repo => @repo)
    cmd.save

    url = "http://2.2.2.2:18000/"
    res = []
    res << JsonResponse.bundle_not_found(cmd).to_json
    res << JsonResponse.new(JsonResponse::SUCCESS, "", {:status => 0, :stdout => "frobnicator echoed"}).to_json

    stub = stub_request(:post, url).with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "shell_exec" and jp["repo"] == "vendor" and jp["bundle"] == "test_bundle" and jp["command"] == "echo"
    }.to_return { { :status => 200, :body => res.shift } }

    stub2 = stub_request(:post, url).with { |req|
      req.body =~ %r{system\\?/provisioning} and req.body =~ /get_bundle.rb/
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {}).to_json).times(3)

    ret = Bixby::RemoteExec.new.exec(@agent, cmd)

    assert_requested(stub, :times => 2)
    assert_requested(stub2, :times => 1)

    assert_equal CommandResponse, ret.class
    assert_equal 0, ret.status
    assert_equal "frobnicator echoed", ret.stdout
    assert ret.success?

    # should have gotten logged
    logs = CommandLog.all.to_a
    assert_equal 3, logs.size

    log = logs.shift
    refute log.exec_status
    assert_equal 404, log.exec_code

    log = logs.shift
    assert log.exec_status
    assert log.stdin
    refute log.args

    log = logs.shift
    assert log.exec_status
    assert_equal 0, log.status
    assert_equal "frobnicator echoed", log.stdout
  end

  def test_provision_failure
    # setup command
    cmd = Command.new(:bundle => @bundle, :command => "echo", :repo => @repo)
    cmd.save

    # stub out requests/responses
    url = "http://2.2.2.2:18000/"
    res = []
    res << JsonResponse.bundle_not_found(cmd).to_json

    # the exec request
    stub = stub_request(:post, url).with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "shell_exec" and jp["repo"] == "vendor" and jp["bundle"] == "test_bundle" and jp["command"] == "echo"
    }.to_return { { :status => 200, :body => res.shift } }

    # the provision request
    stub2 = stub_request(:post, url).with { |req|
      req.body =~ %r{system\\?/provisioning} and req.body =~ /get_bundle.rb/
    }.to_return(:status => 200, :body => JsonResponse.new(JsonResponse::FAIL, "", {}).to_json).times(3)

    # try to exec
    ret = Bixby::RemoteExec.new.exec(@agent, cmd)

    assert_requested(stub, :times => 1)
    assert_requested(stub2, :times => 1)

    assert_equal CommandResponse, ret.class
    refute_equal 0, ret.status
    assert ret.error?
  end

end # Test::Modules::RemoteExec
end # Bixby
