
require 'test_helper'

require 'digest'

class Bixby::Test::Modules::Inventory < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:inventory'
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_nil_pw

    assert_throws(Bixby::API::Error, "password didn't match any known tenants") do
      Bixby::Inventory.new.register_agent(nil, nil, nil, nil, nil)
    end

  end

  def test_nil_org
    t = Tenant.new
    t.password = Digest::MD5.new.hexdigest("test")
    t.name = "test"
    t.save

    assert_throws(Bixby::API::Error, "org not found") do
      Bixby::Inventory.new.register_agent(nil, nil, nil, nil, "test")
    end
  end

  def test_register_agent
    t = Tenant.new
    t.password = Digest::MD5.new.hexdigest("test")
    t.name = "test"
    t.save

    o = Org.new
    o.name = "default"
    o.tenant = t
    o.save

    ip = "4.4.4.4"
    http_req = mock()
    http_req.expects(:remote_ip).returns(ip).twice()

    hostname = "foo.example.com"
    agent = Bixby::Inventory.new(http_req).register_agent("foo", "bar", hostname, 18000, "test")
    assert agent
    assert_equal Agent, agent.class

    host = Host.where("hostname = ?", hostname).first
    assert host, "host created"
    assert_equal hostname, host.hostname, "hostname is set"
    assert_equal ip, host.ip, "ip is set"
  end

  def test_validation_failure
    t = Tenant.new
    t.password = Digest::MD5.new.hexdigest("test")
    t.name = "test"
    t.save

    o = Org.new
    o.name = "default"
    o.tenant = t
    o.save

    http_req = mock()
    http_req.expects(:remote_ip).returns("4.4.4.4").twice()

    assert_throws(Bixby::API::Error) do
      Bixby::Inventory.new(http_req).register_agent("foo", "bar", "foo.example.com", nil, "test")
    end
  end

  def test_update_facts
    agent = FactoryGirl.create(:agent)

    # first update
    jr = JsonResponse.new("success", "", { :status => 0, :stdout => {:uptime => "3 days", :kernel => "Darwin"}.to_json, :stderr => nil })
    stub = stub_request(:post, agent.agent_uri).with { |req|
      req.body =~ /list_facts.rb/
    }.to_return(:status => 200, :body => jr.to_json)

    assert Bixby::Inventory.new.update_facts(agent)

    m = Metadata.all
    assert m
    assert_equal 2, m.size
    assert_equal "uptime", m.first.key
    assert_equal "3 days", m.first.value
    assert_equal 3, m.first.source

    assert_equal "kernel", m.last.key
    assert_equal "Darwin", m.last.value

    # second update, 1 new fact
    jr = JsonResponse.new("success", "", { :status => 0, :stdout => {:domain => "local", :uptime => "3 days", :kernel => "Darwin"}.to_json, :stderr => nil })
    stub = stub_request(:post, agent.agent_uri).with { |req|
      req.body =~ /list_facts.rb/
    }.to_return(:status => 200, :body => jr.to_json)

    assert Bixby::Inventory.new.update_facts(agent)

    m = Metadata.all
    assert m
    assert_equal 3, m.size
    assert_equal "domain", m.last.key
    assert_equal "local", m.last.value

    assert_requested(stub, :times => 2)
  end

end
