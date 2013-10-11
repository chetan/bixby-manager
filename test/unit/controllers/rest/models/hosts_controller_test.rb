
require 'helper'

module Bixby
module Test::Controllers
class Rest::Models::Hosts < TestCase

  tests ::Rest::Models::HostsController

  def setup
    super
    @agent = FactoryGirl.create(:agent)
    @host = FactoryGirl.create(:host)
  end

  def test_show_with_auth
    BIXBY_CONFIG[:crypto] = true

    ApiAuth.sign!(@request, @agent.access_key, @agent.secret_key)
    get :show, :id => @host.id

    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data

    # should get a host object back..
    assert_equal @host.id, data["id"]
    assert_equal @host.ip, data["ip"]
    assert_empty data["tags"]
    assert_empty data["metadata"]
  end

end
end
end
