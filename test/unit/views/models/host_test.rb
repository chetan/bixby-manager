
require "helper"

class Bixby::Test::Views::Models::Host < Bixby::Test::TestCase

  def test_convert
    host = FactoryGirl.create(:host)
    host.update_attributes({:tag_list => "db,prod", :alias => "testing", :desc => "blarney stone"})
    host.add_metadata("uptime", "34 days")
    host.add_metadata("kernel", "darwin")

    json = ApiView::Engine.render(host, nil)

    h = MultiJson.load(json)
    assert h
    assert_includes h, "org"
    assert_includes h, "tags"
    refute_includes h, "metadata"

    assert_equal "db,prod", h["tags"]

    json = ApiView::Engine.render(host, nil, :use => Bixby::ApiView::HostWithMetadata)
    h = MultiJson.load(json)
    assert_equal 2, h["metadata"].size
    m = h["metadata"].first
    assert_includes m.keys, "key"
    assert_includes m.keys, "value"
    assert_includes m.keys, "source"
    assert_equal "uptime", m["key"]
  end

end
