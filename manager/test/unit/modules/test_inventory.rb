
require 'digest'

class TestInventory < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_nil_pw

    assert_throws(API::Error, "password didn't match any known tenants") do
      Inventory.new.register_agent(nil, nil, nil, nil, nil)
    end

  end

  def test_nil_org
    t = Tenant.new
    t.password = Digest::MD5.new.hexdigest("test")
    t.name = "test"
    t.save

    assert_throws(API::Error, "org not found") do
      Inventory.new.register_agent(nil, nil, nil, nil, "test")
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
    agent = Inventory.new(http_req).register_agent("foo", "bar", hostname, 18000, "test")
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

    assert_throws(API::Error) do
      Inventory.new(http_req).register_agent("foo", "bar", "foo.example.com", nil, "test")
    end
  end

end
