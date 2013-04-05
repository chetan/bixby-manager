
require 'test_helper'

module Bixby
class Test::Modules::Monitoring < Bixby::Test::TestCase

  def setup
    super
    ENV["BIXBY_HOME"] = File.join(Rails.root, "test", "support", "root_dir")
    Bixby.instance_eval{ @client = nil }

    @check ||= FactoryGirl.create(:check)
    oncall = FactoryGirl.build(:on_call)
    oncall.org = @check.org
    oncall.save
  end

  def test_require_class
    require "bixby/modules/monitoring"
    assert Bixby.const_defined? :Monitoring
  end

  def test_add_check
    agent = FactoryGirl.create(:agent)

    Bixby::Scheduler.any_instance.expects(:schedule_in).once.with { |time, job|
      time == 0 && job.method == :update_check_config && job.args.first == agent.id
    }

    ret = Bixby::Monitoring.new.add_check(agent.host.id, @check.command, nil)
    assert_kind_of Check, ret

  end

  def test_update_check_config

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
        r = MultiJson.load(req.body)
        r["operation"] == "shell_exec" and r["params"]["command"] == "update_check_config.rb"
      }.
        to_return(:status => 200, :body => cmd_res_json())

    check = FactoryGirl.create(:check)

    Provisioning.any_instance.expects(:provision).once.with { |agent, cmd|
      agent == check.agent and cmd.bundle == check.command.bundle
    }

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

    # make sure we don't alert again
    put_check_result()
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal 2, AlertHistory.all.size

  end

  def test_get_options

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      r = MultiJson.load(req.body)
      rp = r["params"]
      r["operation"] == "shell_exec" and rp["args"] == "--options" and
        rp["command"] == @check.command.command and
        rp.include? "digest" and rp["digest"] =~ /^2429629015110c29/
    }.to_return(:status => 200, :body => cmd_res_json(0, "{}"))

    ret = Bixby::Monitoring.new.get_command_options(@check.agent, @check.command)
    assert_requested stub
    assert ret
    assert_kind_of Hash, ret
  end

  def test_run_check

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      r = MultiJson.load(req.body)
      rp = r["params"]
      r["operation"] == "shell_exec" and rp["args"] == "--monitor" and
        rp["command"] == @check.command.command and
        rp.include? "digest" and rp["digest"] =~ /^2429629015110c29/
    }.to_return(:status => 200, :body => cmd_res_json(0, "{}"))

    ret = Bixby::Monitoring.new.run_check(@check)
    assert_requested stub
    assert ret
    assert_kind_of Hash, ret
  end


  private

  def cmd_res_json(status=0, stdout=nil, stderr=nil)
    res = JsonResponse.new(status == 0 ? "success" : "fail")
    res.data = {
      :status => status,
      :stdout => stdout,
      :stderr => stderr
    }
    return res.to_json
  end

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

    Continuum::Client.any_instance.expects(:metric).with { |n,v,t|
      n =~ /^hardware/ && t.to_i == 1329775841 }.times(4)

    Bixby::Metrics.new.put_check_result(m)
  end

end
end # Bixby
