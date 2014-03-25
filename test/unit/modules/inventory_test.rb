
require 'helper'

require 'digest'

module Bixby
class Test::Modules::Inventory < Bixby::Test::TestCase

  def test_nil_pw

    assert_throws(Bixby::API::Error, "bad tenant and/or password") do
      Bixby::Inventory.new.register_agent(nil)
    end

  end

  def test_nil_org
    t = FactoryGirl.create(:tenant)

    assert_throws(Bixby::API::Error, "bad tenant and/or password") do
      Bixby::Inventory.new.register_agent({ :tenant => t.name, :password => "test" })
    end
  end

  def test_register_agent
    org = FactoryGirl.create(:org)

    now = Time.new.to_i
    Bixby::Scheduler.any_instance.expects(:schedule_at).once().with { |t, job|
      t = t.to_i # a bit of fudge on the time range
      (t >= now+10 || t <= now+11) && job.klass = Bixby::Inventory && job.method == :update_facts
    }

    ip = "4.4.4.4"
    http_req = mock_ip(ip)

    hostname = "foo.example.com"
    ret = Bixby::Inventory.new(http_req).register_agent({
      :uuid => "foo", :public_key => "bar",
      :hostname => hostname,
      :tenant => org.tenant.name,
      :password => "test",
      :tags => "foo,bar",
      :version => "0.5.3"
      })
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
    assert_equal 18000, a.port, "port defaults to 18000"
    assert_equal "0.5.3", a.version

    host = Host.where("hostname = ?", hostname).first
    assert host, "host created"
    assert_equal hostname, host.hostname, "hostname is set"
    assert_equal ip, host.ip, "ip is set"

    assert_equal 3, host.tags.size
    assert_equal 3, host.tags.find_all{ |t| t.name =~ /new|foo|bar/ }.size

    refute_empty Host.tagged_with(["new"])
  end

  def test_validation_failure
    org = FactoryGirl.create(:org)
    http_req = mock_ip("4.4.4.4")

    assert_throws(Bixby::API::Error) do
      Bixby::Inventory.new(http_req).register_agent({
        :uuid => "foo",
        :tenant => org.tenant.name,
        :password => "test"
        })
    end
  end

  def test_update_facts
    repo  = Repo.new(:name => "vendor")
    agent = FactoryGirl.create(:agent)
    cmd   = Command.new(:bundle => "system/inventory", :command => "list_facts.rb", :repo => repo)
    cmd.save


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

    old_hostname = agent.host.hostname

    # second update, 1 new fact
    jr = JsonResponse.new("success", "", { :status => 0, :stdout => {:domain => "local", :uptime => "4 days", :kernel => "Darwin", :hostname => "foo.host.com"}.to_json, :stderr => nil })
    stub = stub_request(:post, agent.uri).with { |req|
      req.body =~ /list_facts.rb/
    }.to_return(:status => 200, :body => jr.to_json)

    assert Bixby::Inventory.new.update_facts(agent)

    m = Metadata.all
    assert m
    assert_equal 4, m.size
    assert_equal "domain", m[2].key
    assert_equal "local", m[2].value
    assert_equal "4 days", m.first.value

    refute_equal old_hostname, agent.host.hostname
    assert_equal "foo.host.com", agent.host.hostname

    assert_requested(stub, :times => 2)
  end

  def test_update_version
    stub_api.expect{ |agent, op, params|
      params[:bundle] == "system/inventory" && params[:command] == "get_agent_version.rb"
      }.returns(CommandResponse.new({:status => 0, :stdout => "1.5.19"}))

    repo  = Repo.new(:name => "vendor")
    agent = FactoryGirl.create(:agent)
    cmd   = Command.new(:bundle => "system/inventory", :command => "get_agent_version.rb", :repo => repo)
    cmd.save

    Bixby::Inventory.new.update_version(agent)
    assert_equal "1.5.19", agent.version

    assert_api_requests
  end


  private

  def mock_ip(ip)
    http_req = mock()
    http_req.expects(:ip).returns(ip).once()
    return http_req
  end


end
end
