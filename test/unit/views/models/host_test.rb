
require "helper"

class Bixby::Test::Views::Models::Host < Bixby::Test::TestCase

  def test_convert
    host = FactoryGirl.create(:host)
    host.update_attributes({:tag_list => "db,prod", :alias => "testing", :desc => "blarney stone"})
    host.metadata += FactoryGirl.create_list(:metadata, 2)

    json = ApiView::Engine.render(host, nil)

    h = MultiJson.load(json)
    assert h
    assert_includes h, "org"
    assert_includes h, "tags"
    assert_includes h, "metadata"

    assert_equal "db,prod", h["tags"]
    assert_equal 2, h["metadata"].size
    m = h["metadata"].first
    assert_includes m.keys, "key"
    assert_includes m.keys, "value"
    assert_includes m.keys, "source"
    assert_equal "uptime", m["key"]
  end

end
