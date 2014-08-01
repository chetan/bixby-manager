
require 'helper'

module Bixby
module Test::Controllers
class Rest::Models::Hosts < TestCase

  tests ::Rest::Models::HostsController

  def setup
    super
    # Create a user and sign him in
    @user = FactoryGirl.create(:user)
    # sign_in @user
  end

  def test_index
    sign_with_agent

    # add another host to make sure we get both back
    h = FactoryGirl.create(:host)
    h.org = @host.org
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


  private

  def host_assertions(host, expected)
    p host
    assert_equal expected.id, host["id"]
    assert_equal expected.ip, host["ip"]
    assert_equal expected.org.name, host["org"]
    assert_empty host["tags"]
    assert_empty host["metadata"]
  end

end
end
end
