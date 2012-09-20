
require 'test_helper'

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
module Test
module Controllers

class API < ActionController::TestCase

  def setup
    @controller = ApiController.new
    SimpleCov.command_name 'test:controllers:api'
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
    agent = FactoryGirl.create(:agent)
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hi", "joe").to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "hello joe", res.data
  end

  def test_params_array
    agent = FactoryGirl.create(:agent)
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:msg", %w(hi there)).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "msg: hi there", res.data
  end

  def test_params_hash
    agent = FactoryGirl.create(:agent)
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:hash", {:msg => "yo boss"}).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    assert res.success?
    assert "yo boss", res.data
  end

  def test_catch_exception
    agent = FactoryGirl.create(:agent)
    @request.env['RAW_POST_DATA'] = JsonRequest.new("hello:err", "joe").to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    refute res.success?
    assert_equal 500, res.code
    assert_equal "ahhh", res.message
  end

  private

  def unsupported_op(op, param)
    agent = FactoryGirl.create(:agent)
    @request.env['RAW_POST_DATA'] = JsonRequest.new(op, param).to_json
    post :handle

    res = JsonResponse.from_json(@response.body)
    assert res
    refute res.success?
    assert res.message =~ /unsupported operation/
    assert_equal 400, res.code
  end

end # API

end
end
end
