
require 'test_helper'

class TestMetrics < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:metrics'
    WebMock.reset!
  end

  def teardown
  end

  def test_require_class
    require "bixby/modules/metrics"
    assert Bixby.const_defined? :Metrics
  end

  def test_has_default_driver
    assert Bixby::Metrics.driver
    assert Bixby::Metrics.driver == Bixby::Metrics::OpenTSDB
  end

  def test_put
    t = Time.new
    mock = TCPSocket.any_instance.stubs(:sendmsg).with{ |v| v =~ /foobar/ and v.include? t.to_i.to_s }.once()
    Bixby::Metrics.new.put("foobar", 37, t, {})
  end

  def test_put_check_result

    c = FactoryGirl.create(:check)

    m = {"timestamp"=>1329775841, "metrics"=>[
        {"metrics"=>{"size"=>297, "used"=>202, "free"=>94, "usage"=>69},
         "metadata"=>{"mount"=>"/", "type"=>"hfs"}}],
      "errors"=>[], "status"=>"OK", "check_id"=>c.id,
      "key"=>"hardware.storage.disk"}

    mock = TCPSocket.any_instance.stubs(:sendmsg).with{ |v| v =~ /hardware/ and v.include? 1329775841.to_s }.times(4)
    assert Bixby::Metrics.new.put_check_result(m)

    # make sure metrics records got written
    assert Metric.find(:all).size == 4
    m = Metric.where(:key => "hardware.storage.disk.size").first
    assert m
    assert_equal 297, m.last_value.to_i

  end

  def test_driver_must_override_methods
    assert_throws(NotImplementedError) do
      FooDriver.configure(nil)
    end
    assert_throws(NotImplementedError) do
      FooDriver.put(nil, nil, nil, nil)
    end
  end

  def test_get
    stub, req = create_req()
    ret = Bixby::Metrics.new.get(req)
    assert_requested(stub)
    assert ret
    test_metric_row(ret)
  end

  def test_multi_get
    stub, req = create_req()
    ret = Bixby::Metrics.new.multi_get([ req ])
    assert_requested(stub)
    assert ret
    assert_kind_of Array, ret
    assert_kind_of Hash, ret.first
    assert_equal 1, ret.size
    test_metric_row(ret.first)
  end

  def test_get_for_host
    m = FactoryGirl.create(:metric)
    test_get_host(m.check.host)
  end

  def test_get_for_host_by_id
    m = FactoryGirl.create(:metric)
    test_get_host(m.check.host.id.to_s)
  end

  class FooDriver < Bixby::Metrics::Driver
  end



  private

  def test_get_host(host)
    stub, req = create_req()
    ret = Bixby::Metrics.new.get_for_host(host, Time.new-86400, Time.new, {:foo=>"bar"})

    assert_requested(stub)
    assert ret
    assert_kind_of Array, ret

    metric = ret.first
    assert_kind_of Metric, metric
    assert metric.data
    assert metric.tags
    assert_equal 2, metric.data.size
    assert_equal 7, metric.tags.size
  end

  def create_req
    body = <<-EOF
hardware.storage.disk.free 1336748410 86 org_id=1 host_id=3 host=127.0.0.1 mount=/ check_id=1 tenant_id=1 type=hfs
hardware.storage.disk.free 1336748470 86 org_id=1 host_id=3 host=127.0.0.1 mount=/ check_id=1 tenant_id=1 type=hfs
EOF
    stub = stub_request(:get, /:4242/).with { |req|
      uri = req.uri.to_s
      uri.include? "m=" and uri =~ /sum:hardware.storage.disk.free/ and uri =~ /foo=bar/
    }.to_return(:status => 200, :body => body)

    s = Time.new - 86400
    e = Time.new

    return stub, { :key => "hardware.storage.disk.free", :start_time => s, :end_time => e, :agg => "sum", :tags => {:foo => "bar"} }
  end

  def test_metric_row(ret)
    assert_kind_of Hash, ret
    [:key, :tags, :vals].each { |k| assert ret.include? k }

    tags = ret[:tags]
    %w(org_id host_id host mount check_id tenant_id type).each { |k| assert tags.include? k }
    assert_equal "127.0.0.1", tags["host"]

    assert_equal 2, ret[:vals].size
    assert_equal 1336748410, ret[:vals].first[:time]
    assert_equal 86, ret[:vals].first[:val]

  end

end
