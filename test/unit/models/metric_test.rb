
require "helper"

class Bixby::Test::Models::Metric < Bixby::Test::TestCase

  def setup
    super

    # tests written against opentsdb
    Bixby::Metrics.driver = Bixby::Metrics::OpenTSDB
    Bixby::Metrics.driver.configure(BIXBY_CONFIG)

    @body1 = <<-EOF
hardware.storage.disk.free 1336748410 86 org_id=1 host_id=3 host=127.0.0.1 mount=/ check_id=1 tenant_id=1 type=hfs
EOF
    @body2 = <<-EOF
hardware.storage.disk.free 1336748410 86 org_id=1 host_id=3 host=127.0.0.1 mount=/ check_id=1 tenant_id=1 type=hfs
hardware.storage.disk.free 1336748470 86 org_id=1 host_id=3 host=127.0.0.1 mount=/ check_id=1 tenant_id=1 type=hfs
EOF
    m = FactoryGirl.create(:metric)

    @host = m.check.host
    mi = FactoryGirl.build(:metric_info)
    mi.command = m.check.command
    mi.save!
  end

  def test_metrics_for_host
    stub, req = create_req(@body2)

    m = Metric.first
    m.created_at = m.created_at - 86400 # force it to be "old"
    m.save

    metrics = Metric.metrics_for_host(@host, nil, nil, req[:tags])
    assert_requested(stub)
    common_tests(metrics)
  end

  def test_load_data
    m = Metric.first
    assert m
    assert_kind_of Metric, m

    stub = stub_request(:get, /:4242/).with { |req|
      u = req.uri.to_s
      u =~ /ascii=true/ && u =~ /sum:hardware.storage.disk.free/ &&
        u =~ /check_id=#{m.check.id}/
    }

    m.load_data!
    assert_requested(stub)
    refute m.data
    refute m.metadata
  end

  def test_metrics_for_host_no_downsample
    m = Metric.first
    m.created_at = m.created_at - 86400 # force it to be "old"
    m.save

    stub2, req2 = create_req(@body2, "")
    stub1, req1 = create_req(@body1)
    metrics = Metric.metrics_for_host(@host, nil, nil, req1[:tags])
    assert_requested(stub1)
    assert_requested(stub2)
    common_tests(metrics)
  end

  def test_metrics_for_host_no_downsample_new_metric
    stub, req = create_req(@body2, ":5m-avg")
    metrics = Metric.metrics_for_host(@host, nil, nil, req[:tags])
    assert_requested(stub)
    common_tests(metrics)
  end


  private

  def common_tests(metrics)
    assert metrics
    assert_kind_of Array, metrics
    assert_equal 1, metrics.size

    json = ApiView::Engine.render(metrics.first, nil)
    m = MultiJson.load(json)
    assert_kind_of Hash, m
    %w{check_id key status desc unit data metadata}.each { |k| assert m.include?(k), "includes #{k}" }
    refute m.include? "created_at"
    assert_kind_of Fixnum, m["check_id"]
    assert_equal 2, m["data"].size
    %w{x y}.each { |k| assert m["data"].first.include? k }
  end

  def create_req(body, downsample=":1h-avg")
    stub = stub_request(:get, /:4242/).with { |req|
      uri = req.uri.to_s
      m = "m=sum#{downsample}:hardware.storage.disk.free"
      uri =~ /#{m}/ and uri =~ /foo=bar/
    }.to_return(:status => 200, :body => body)

    s = Time.new - 86400
    e = Time.new

    return stub, { :key => "hardware.storage.disk.free", :start_time => s, :end_time => e, :agg => "sum", :tags => {:foo => "bar"} }
  end

end
