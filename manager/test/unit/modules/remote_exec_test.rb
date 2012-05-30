
require 'test_helper'

class Bixby::Test::Modules::RemoteExec < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:remote_exec'
    WebMock.reset!
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_create_spec
      c = CommandSpec.new(:repo => "support", :bundle => "foobar")
      assert_equal c, Bixby::RemoteExec.create_spec(c)

      c = CommandSpec.new(:repo => "support", :bundle => "foobar")
      s = Bixby::RemoteExec.create_spec(c.to_json)
      assert_equal c.repo, s.repo
      assert_equal c.bundle, s.bundle

      repo = Repo.new(:name => "vendor")
      cmd = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)
      cs = Bixby::RemoteExec.create_spec(cmd)

      assert_not_equal cs, cmd
      assert_equal "baz", cs.command
      assert_equal "foobar", cs.bundle

  end

  def test_exec
    repo  = Repo.new(:name => "vendor")
    agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    cmd   = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "exec" and jp["repo"] == "vendor" and jp["bundle"] == "foobar" and jp["command"] == "baz"
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json)

    ret = Bixby::RemoteExec.exec(agent, cmd)

    assert_requested(stub)
    assert ret.success?
  end

  def test_exec_with_provision

    BundleRepository.path = "#{Rails.root}/test"
    repo  = Repo.new(:name => "support")
    agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    cmd   = Command.new(:bundle => "test_bundle", :command => "echo", :repo => repo)

    url = "http://2.2.2.2:18000/"
    res = []
    res << JsonResponse.bundle_not_found(cmd).to_json
    res << JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json

    stub = stub_request(:post, url).with { |req|
      j = MultiJson.load(req.body)
      jp = j["params"]
      j["operation"] == "exec" and jp["repo"] == "support" and jp["bundle"] == "test_bundle" and jp["command"] == "echo"
    }.to_return { { :status => 200, :body => res.shift } }

    stub2 = stub_request(:post, url).with { |req|
      req.body =~ %r{system\\?/provisioning} and req.body =~ /get_bundle.rb/
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {}).to_json).times(3)

    ret = Bixby::RemoteExec.exec(agent, cmd)

    assert_requested(stub, :times => 2)
    assert_requested(stub2, :times => 1)

    assert_equal CommandResponse, ret.class
    assert_equal 0, ret.status
    assert_equal "frobnicator echoed", ret.stdout
    assert ret.success?
  end

end
