
class Bixby::Test::Models::Metric < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:metrics'
    DatabaseCleaner.start
    WebMock.reset!
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
    mi.command_id = m.check.command.id
    mi.save!
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_metrics_for_host
    stub, req = create_req(@body2)

    metrics = Metric.metrics_for_host(@host, nil, nil, req[:tags])
    assert_requested(stub)
    common_tests(metrics)
  end

  def test_metrics_for_host_no_downsample
    stub2, req2 = create_req(@body2, false)
    stub1, req1 = create_req(@body1)
    metrics = Metric.metrics_for_host(@host, nil, nil, req1[:tags])
    assert_requested(stub1)
    assert_requested(stub2)
    common_tests(metrics)
  end


  private

  def common_tests(metrics)
    assert metrics
    assert_kind_of Array, metrics
    assert_equal 1, metrics.size

    m = metrics.first
    assert_kind_of Hash, m
    (%w(check_id key status desc unit)+[:data, :metadata]).each { |k| assert m.include? k }
    refute m.include? "created_at"
    assert_kind_of Fixnum, m["check_id"]
    assert_equal 2, m[:data].size
    [:x, :y].each { |k| assert m[:data].first.include? k }
  end

  def create_req(body, downsample=true)
    stub = stub_request(:get, /:4242/).with { |req|
      uri = req.uri.to_s
      m = "m=sum" + (downsample ? ":1h-avg" : "") + ":hardware.storage.disk.free"
      uri =~ /#{m}/ and uri =~ /foo=bar/
    }.to_return(:status => 200, :body => body)

    s = Time.new - 86400
    e = Time.new

    return stub, { :key => "hardware.storage.disk.free", :start_time => s, :end_time => e, :agg => "sum", :tags => {:foo => "bar"} }
  end

end
