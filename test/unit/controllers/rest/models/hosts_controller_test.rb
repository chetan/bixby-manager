
require 'helper'

module Bixby
module Test::Controllers
class Rest::Models::Hosts < TestCase

  tests ::Rest::Models::HostsController

  def setup
    super
    @user = FactoryGirl.create(:user)
  end

  def test_index
    sign_with_agent

    # add another host to make sure we get both back
    h = FactoryGirl.create(:agent).host
    h.org_id = @host.org.id
    h.save!

    get :index
    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data
    assert_kind_of Array, data
    assert_equal 2, data.size
    host_assertions(data.first, @host)
    host_assertions(data.last, h)
  end

  def test_show
    sign_with_agent
    get :show, :id => @host.id

    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data
    host_assertions(data, @host)
  end

  def test_tenant_security

    sign_in @user

    h = FactoryGirl.create(:host)
    assert h.respond_to? :tenant
    assert h.tenant
    assert_equal h.org.tenant, h.tenant

    h2 = FactoryGirl.create(:host)
    refute_equal h.tenant, h2.tenant

    # now try to load h2 and fail
    change_tenant(h.tenant)
    get :show, :id => h2.id
    assert_response 302
    assert @response.headers["Location"] =~ %r{/inventory$}

    # doesn't throw
    change_tenant(h.tenant)
    get :show, :id => h.id
    assert_response 200

    change_tenant(h2.tenant)
    get :show, :id => h2.id
    assert_response 200
  end

  def test_metadata
    h = FactoryGirl.create(:host)
    sign_in @user
    h.org = @user.org
    h.save
    h.add_metadata("uptime", "34 days")
    h.add_metadata("kernel", "darwin")

    get :metadata, :id => h.id
    assert_response 200
    data = MultiJson.load(response.body)
    assert data
    refute_empty data
    assert_equal "uptime", data.first["key"]
    assert_equal "darwin", data.last["value"]
  end


  private

  def host_assertions(host, expected)
    p host
    assert_equal expected.id, host["id"]
    assert_equal expected.ip, host["ip"]
    assert_equal expected.org.name, host["org"]
    assert_empty host["tags"]
    refute host["metadata"]
  end

end
end
end
