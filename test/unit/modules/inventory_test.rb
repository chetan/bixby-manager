
require 'test_helper'

require 'digest'

module Bixby
class Test::Modules::Inventory < Bixby::Test::TestCase

  def test_nil_pw

    assert_throws(Bixby::API::Error, "bad tenant and/or password") do
      Bixby::Inventory.new.register_agent(nil, nil, nil, nil, nil, nil)
    end

  end

  def test_nil_org
    t = FactoryGirl.create(:tenant)

    assert_throws(Bixby::API::Error, "bad tenant and/or password") do
      Bixby::Inventory.new.register_agent(nil, nil, nil, nil, t.name, "test")
    end
  end

  def test_register_agent
    org = FactoryGirl.create(:org)

    Bixby::Scheduler.any_instance.expects(:schedule_in).once().with { |interval, job|
      interval == 10 && job.klass = Bixby::Inventory && job.method == :update_facts
    }

    ip = "4.4.4.4"
    http_req = mock_ip("4.4.4.4")

    hostname = "foo.example.com"
    ret = Bixby::Inventory.new(http_req).register_agent("foo", "bar", hostname, 18000, org.tenant.name, "test")
    assert ret
    assert_kind_of Hash, ret
    assert_equal 3, ret.keys.size
    assert_includes ret, :server_key
    assert_includes ret, :access_key
    assert_includes ret, :secret_key
    assert ret[:server_key] =~ /PUBLIC KEY/
    assert_equal 32, ret[:access_key].length
    assert_equal 128, ret[:secret_key].length

    a = Agent.where(:uuid => "foo").first
    assert a, "agent created"
    assert_equal ret[:access_key], a.access_key
    assert_equal ret[:secret_key], a.secret_key

    host = Host.where("hostname = ?", hostname).first
    assert host, "host created"
    assert_equal hostname, host.hostname, "hostname is set"
    assert_equal ip, host.ip, "ip is set"

    refute_empty Host.tagged_with(["new"])
  end

  def test_validation_failure
    org = FactoryGirl.create(:org)
    http_req = mock_ip("4.4.4.4")

    assert_throws(Bixby::API::Error) do
      Bixby::Inventory.new(http_req).register_agent("foo", "bar", "foo.example.com", nil, org.tenant.name, "test")
    end
  end

  def test_update_facts
    agent = FactoryGirl.create(:agent)

    # first update
    jr = JsonResponse.new("success", "", { :status => 0, :stdout => {:uptime => "3 days", :kernel => "Darwin"}.to_json, :stderr => nil })
    stub = stub_request(:post, agent.uri).with { |req|
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
    stub = stub_request(:post, agent.uri).with { |req|
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


  private

  def mock_ip(ip)
    http_req = mock()
    http_req.expects(:ip).returns(ip).once()
    return http_req
  end


end
end
