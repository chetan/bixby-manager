
class TestMetrics < ActiveSupport::TestCase

  def setup
    WebMock.disable!
  end

  def teardown
    WebMock.enable!
  end

  def test_require_class
    require "modules/metrics"
    assert Object.const_defined? :Metrics
  end

  def test_has_default_driver
    assert Metrics.driver
    assert Metrics.driver == Metrics::OpenTSDB
  end

  def test_put
    t = Time.new
    mock = TCPSocket.any_instance.stubs(:sendmsg).with{ |v| v =~ /foobar/ and v.include? t.to_i.to_s }.once()
    Metrics.new.put("foobar", 37, t, {})
  end

  def test_driver_must_override_methods
    assert_throws(NotImplementedError) do
      FooDriver.configure(nil)
    end
    assert_throws(NotImplementedError) do
      FooDriver.put(nil, nil, nil, nil)
    end
  end

  class FooDriver < Metrics::Driver
  end

end
