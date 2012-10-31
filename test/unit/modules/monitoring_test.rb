
require 'test_helper'

module Bixby
class Test::Modules::Monitoring < Bixby::Test::TestCase

  def setup
    super
    @check ||= FactoryGirl.create(:check)
    oncall = FactoryGirl.build(:on_call)
    oncall.org = @check.org
    oncall.save
  end

  def test_require_class
    require "bixby/modules/monitoring"
    assert Bixby.const_defined? :Monitoring
  end

  def test_update_check_config

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
        r = MultiJson.load(req.body)
        r["operation"] == "exec" and r["params"]["command"] == "ruby_wrapper.rb" and req.body =~ /update_check_config.rb/
      }.
        to_return(:status => 200, :body => JsonResponse.new("success", "", {:status => 0, :stdout => ""}).to_json)
        # with(:body => "{\"operation\":\"exec\",\"params\":{\"bundle\":\"system/monitoring\",\"command\":\"ruby_wrapper.rb\",\"repo\":\"vendor\",\"stdin\":\"[{\\\"interval\\\":null,\\\"retry\\\":null,\\\"timeout\\\":null,\\\"command\\\":{\\\"bundle\\\":\\\"foo\\\",\\\"command\\\":\\\"bar\\\",\\\"repo\\\":\\\"repo\\\",\\\"stdin\\\":\\\"{\\\\\\\"check_id\\\\\\\":2}\\\"}}]\",\"digest\":\"0e75fa55f550f8abb6c726356ea9d2c65a4cec2abd762a37b29b13898a9eaafb\",\"args\":\"vendor/system/monitoring/bin/update_check_config.rb -- \"}}").

    check = FactoryGirl.create(:check)
    ret = Bixby::Monitoring.new.update_check_config(check.agent)

    assert_requested(stub)
    assert_kind_of CommandResponse, ret

  end

  def test_alerting_on_metrics
    put_check_result()
    m = Metric.where(:key => "hardware.storage.disk.size").first

    a = Alert.new
    a.metric = m
    a.severity = Alert::Severity::CRITICAL
    a.threshold = 280
    a.sign = :gt
    a.save!

    # try again, this should generate an email
    put_check_result()

    refute_empty ActionMailer::Base.deliveries
    assert_equal 1, ActionMailer::Base.deliveries.size

    # check that history was recorded
    ah = AlertHistory.all
    refute_empty ah
    assert_equal 1, ah.size

    ah = ah.first
    assert ah
    assert_equal a.id, ah.alert_id
    assert_equal 280, ah.threshold

    # if we alert again, there should be no state change
    put_check_result()

    refute_empty ActionMailer::Base.deliveries
    assert_equal 1, ActionMailer::Base.deliveries.size # still 1
    assert_equal 1, AlertHistory.all.size

    # now modify the alert so it returns to normal on next put
    a.threshold = 300
    a.save!

    put_check_result()
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal 2, AlertHistory.all.size

    ah = AlertHistory.last
    assert_equal a.id, ah.alert_id
    assert_equal 300, ah.threshold
    assert_equal Alert::Severity::CRITICAL, ah.severity

  end


  private

  def put_check_result
    m = {
          "timestamp" => 1329775841,
          "metrics" => [
            {
              "metrics"  => { "size"=>297, "used"=>202, "free"=>94, "usage"=>69 },
              "metadata" => { "mount"=>"/", "type"=>"hfs" }
            }
          ],
        "errors"=>[], "status"=>"OK", "check_id"=>@check.id,
        "key"=>"hardware.storage.disk"
    }

    mock = TCPSocket.any_instance.stubs(:sendmsg).with{ |v| v =~ /hardware/ and v.include? 1329775841.to_s }.times(4)
    Bixby::Metrics.new.put_check_result(m)
  end

end
end # Bixby
