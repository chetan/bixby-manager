
require "helper"

class Bixby::Test::Views::Models::Metric < Bixby::Test::TestCase

  def test_convert

    metric = FactoryGirl.create(:metric)
    metric.metadata = { "foo" => "bar" }
    metric.query = { :start => Time.new-86400, :end => Time.new, :downsample => "1h-avg" }
    metric.data = [ {:time => Time.new, :val => 3 }, {:time => Time.new-60, :val => 4 } ]

    json = ApiView::Engine.render(metric, nil)
    assert json

    m = MultiJson.load(json)
    assert m
    assert_equal metric.id, m["id"]

    %w{id check_id key name last_value status updated_at metadata query}.each do |k|
      assert_includes m, k, "metric should include #{k}"
    end

    assert_equal 2, m["data"].size
    q = m["query"]
    assert q
    assert_equal metric.query[:start].to_i, q["start"].to_i
    assert_equal metric.data.first[:time].to_i, m["data"].first["x"].to_i

  end

end
