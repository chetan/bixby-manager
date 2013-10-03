
require "helper"

class Bixby::Test::Views::Models::MetricInfo < Bixby::Test::TestCase

  def test_convert
    m = FactoryGirl.create(:metric_info)
    json = ApiView::Engine.render(m, nil)
    h = MultiJson.load(json)

    assert h
    %w(id metric unit desc label).each do |key|
      assert_includes h, key
    end
    refute_includes h, "command_id"
  end

end
