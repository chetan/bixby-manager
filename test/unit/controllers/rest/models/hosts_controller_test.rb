
require 'helper'

module Bixby
module Test::Controllers
class Rest::Models::Hosts < TestCase

  tests ::Rest::Models::HostsController

  def setup
    super
    @agent = FactoryGirl.create(:agent)
    @host = Host.first
    BIXBY_CONFIG[:crypto] = true
    ApiAuth.sign!(@request, @agent.access_key, @agent.secret_key)
  end

  def test_index

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
    get :show, :id => @host.id

    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data
    host_assertions(data, @host)
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
