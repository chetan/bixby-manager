
require 'helper'
require 'rack/test'

module Bixby
module Test

  class TestServer < TestCase

    include Rack::Test::Methods

    def setup
      super
      setup_existing_agent()
    end

    def app
      Bixby::Server.agent = @agent
      Bixby::Server
    end

    def test_get_is_invalid
      get "/foobar"
      assert_equal 200, last_response.status
      assert last_response.body =~ /invalid request/
    end

    def test_post_empty_req
      post "/foobar"
      assert_equal 200, last_response.status
      assert last_response.body =~ /invalid request/
    end

    def test_post_bad_json
      post "/foobar", "hi there"
      assert_equal 200, last_response.status
      assert last_response.body =~ /invalid request/
    end

    def test_post_invalid_op
      post "/foobar", JsonRequest.new("hi", {}).to_json
      assert_equal 200, last_response.status
      assert last_response.body =~ /unsupported operation/
    end

    def test_exec
      `ls` # hack to create a Process::Status object we can pass to our stub
      @agent.expects(:exec).once().returns([$?, "", ""])
      post "/foobar", JsonRequest.new("exec", {}).to_json

      assert_equal 200, last_response.status
      res = JsonResponse.from_json(last_response.body)
      assert res.success?
      assert_equal 0, res.data["status"]
    end

    def test_exec_encrypted
      ENV["BIXBY_NOCRYPTO"] = "0"
      `ls` # hack to create a Process::Status object we can pass to our stub
      @agent.expects(:exec).once().returns([$?, "", ""])
      post "/foobar", encrypt_for_agent( JsonRequest.new("exec", {}).to_json )

      assert_equal 200, last_response.status
      json = decrypt_from_agent(last_response.body)
      res = JsonResponse.from_json(json)
      assert res.success?
      assert_equal 0, res.data["status"]
    end

  end

end
end
