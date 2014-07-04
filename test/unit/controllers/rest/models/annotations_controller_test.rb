
require 'helper'

module Bixby
module Test::Controllers
class Rest::Models::Annotations < TestCase

  tests ::Rest::Models::AnnotationsController

  def setup
    super
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  def test_index
    Bixby::Metrics.new(nil, nil, @user).add_annotation("foobar", [], nil, "baz")
    get :index
    common_assertions
  end

  def test_index_by_name
    Bixby::Metrics.new(nil, nil, @user).add_annotation("frobnicate", [], nil, "bar")
    Bixby::Metrics.new(nil, nil, @user).add_annotation("foobar", [], nil, "baz")
    get :index, :name => "foobar"
    common_assertions
  end

  def test_index_by_detail
    Bixby::Metrics.new(nil, nil, @user).add_annotation("foobar", [], nil, MultiJson.dump({:user => "joe"}))
    Bixby::Metrics.new(nil, nil, @user).add_annotation("foobar", [], nil, MultiJson.dump({:user => "john"}))
    get :index, :name => "foobar", :detail => "user=joe"
    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data
    assert_kind_of Array, data
    assert_equal 1, data.size
    detail = MultiJson.load(data.first["detail"])
    assert_equal "joe", detail["user"]
  end


  private

  def common_assertions
    assert @response
    assert_response 200

    data = MultiJson.load(@response.body)
    assert data
    assert_kind_of Array, data
    assert_equal 1, data.size
    a = data.first
    assert a
    assert_equal "foobar", a["name"]
    assert_equal "baz", a["detail"]
    assert_empty a["tags"]
  end

end
end
end
