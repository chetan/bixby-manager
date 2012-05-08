
class TestMetrics < ActiveSupport::TestCase

  def setup
    WebMock.disable!
    @check = Check.new
  end

  def teardown
    WebMock.enable!
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

    Bixby::Metrics.new.put_check_result(m)
  end

  def test_driver_must_override_methods
    assert_throws(NotImplementedError) do
      FooDriver.configure(nil)
    end
    assert_throws(NotImplementedError) do
      FooDriver.put(nil, nil, nil, nil)
    end
  end

  class FooDriver < Bixby::Metrics::Driver
  end

end
