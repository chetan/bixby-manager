
require 'helper'

class Bixby::Hello < Bixby::API
  def hi(name)
    return "hello #{name}"
  end

  def msg(foo, bar)
    return "msg: #{foo} #{bar}"
  end

  def err(foo)
    raise Exception.new("ahhh")
  end

  def hash(hash)
    return hash[:msg]
  end
end

module Bixby
module Test::Controllers

class API < TestCase

  def setup
    super
    @controller = ApiController.new
    @agent = FactoryGirl.create(:agent)
  end

  def test_post_invalid
    post :handle
    assert @response.body =~ /invalid request/

    @request.recycle!
    @request.env['RAW_POST_DATA'] = "aslkdjafsdf"
    post :handle
    assert @response.body =~ /invalid request/

    @request.recycle!
    @request.env['RAW_POST_DATA'] = JsonRequest.new(nil, nil).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    refute res.success?
    assert @response.body =~ /invalid request/
    assert res.message =~ /invalid request/
  end

  def test_unsupported_op
    unsupported_op("hello", "joe")
    unsupported_op("foo:bar", "joe")
    unsupported_op("hello:world", "joe")
  end

  def test_valid_request
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hi", "joe").to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "hello joe", res.data
  end

  def test_signed_request_succeeds
    BIXBY_CONFIG[:crypto] = true

    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hi", "joe").to_json
    ApiAuth.sign!(@request, @agent.access_key, @agent.secret_key)
    post :handle

    # validate response
    body = @response.body
    res = JsonResponse.from_json(body)
    assert res
    assert res.success?
    assert "hello joe", res.data
  end

  def test_unsigned_request_fails
    BIXBY_CONFIG[:crypto] = true

    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hi", "joe").to_json
    post :handle

    body = @response.body
    res = JsonResponse.from_json(body)
    assert res
    refute res.success?
    assert_equal 401, res.code
  end

  def test_signed_request_fails
    BIXBY_CONFIG[:crypto] = true

    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hi", "joe").to_json
    ApiAuth.sign!(@request, "asdf", @agent.secret_key)
    post :handle

    body = @response.body
    res = JsonResponse.from_json(body)
    assert res
    refute res.success?
    assert_equal 401, res.code
  end

  def test_params_array
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:msg", %w(hi there)).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "msg: hi there", res.data
  end

  def test_params_hash
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hash", {:msg => "yo boss"}).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "yo boss", res.data
  end

  def test_catch_exception
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:err", "joe").to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    refute res.success?
    assert_equal 500, res.code
    assert_equal "ahhh", res.message
  end

  def test_is_async
    assert Bixby.is_async?(Bixby::Metrics, :put_check_result)
  end

  def test_async_call_is_scheduled
    @request.env['RAW_POST_DATA'] = JsonRequest.new("metrics:put_check_result", [ "foo", "bar"]).to_json

    Bixby.expects(:is_async?).once.with{ |klass, method|
      klass == Bixby::Metrics && method == :put_check_result
    }.returns(true)

    Bixby.expects(:do_async).once.with do |klass, method, args|
      klass == Bixby::Metrics && method == :put_check_result && (args.kind_of? Array and args.first == "foo")
    end

    Bixby::Metrics.any_instance.expects(:put_check_result).never

    post :handle
    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert_nil res.data
  end

  def test_agent_register_succeeds

    # testing with crypto enabled, registration should still occur
    BIXBY_CONFIG[:crypto] = true

    org = FactoryGirl.create(:org)
    params = { :uuid => "my_uuid", :public_key => "my_key",
                :hostname => "testhost", :port => 18000,
                :tenant => org.tenant.name, :password => "test" }

    req = JsonRequest.new("inventory:register_agent", params)
    @request.env['RAW_POST_DATA'] = req.to_json

    Bixby::Scheduler.any_instance.expects(:schedule_at).with do |t, job|
      t = t.to_i # a bit of fudge on the time range
      (t >= Time.now.to_i+10 || t <= Time.now.to_i+11) && job.klass = Bixby::Inventory && job.method == :update_facts
    end

    post :handle
    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
  end



  private

  def unsupported_op(op, param)
    @request.env['RAW_POST_DATA'] = JsonRequest.new(op, param).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    refute res.success?
    assert res.message =~ /unsupported operation/
    assert_equal 400, res.code
  end

  def key_for(key)
    OpenSSL::PKey::RSA.new(key)
  end

  def encrypt_for_server(agent, payload)
    server_pem = OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
    agent_pem = OpenSSL::PKey::RSA.new(agent.private_key)
    Bixby::CryptoUtil.encrypt(payload, agent.uuid, server_pem, agent_pem)
  end

  def decrypt_from_server(agent, payload)
    server_pem = OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
    agent_pem = OpenSSL::PKey::RSA.new(agent.private_key)
    payload = StringIO.new(payload)
    payload.readline # throw away the uuid
    Bixby::CryptoUtil.decrypt(payload, agent_pem, server_pem)
  end

end # API

end
end
