
require 'helper'
require 'setup/sidekiq_mock_redis'

module Bixby
class Test::Modules::Monitoring < Bixby::Test::TestCase

  include ActiveJob::TestHelper

  def setup
    super
    Resque.redis = MockRedis.new

    ENV["BIXBY_HOME"] = File.join(Rails.root, "test", "support", "root_dir")
    Bixby.instance_eval{ @client = nil }

    Bixby::Metrics.driver = Bixby::Metrics::OpenTSDB
    Bixby::Metrics.driver.configure(BIXBY_CONFIG)

    @check ||= FactoryGirl.create(:check)
    oncall = FactoryGirl.build(:on_call)
    oncall.org = @check.org
    oncall.save
  end

  def test_require_class
    require "bixby/modules/monitoring"
    assert Bixby.const_defined? :Monitoring
  end

  def test_add_check_on_register_any
    common_add_check_on_register("any", "dev,foo", 1)
  end

  def test_add_check_on_register_all_no_match
    common_add_check_on_register("all", "dev,foo", 0)
  end

  def test_add_check_on_register_all_match
    common_add_check_on_register("all", "bar,foo", 1)
  end

  def test_add_check_on_register_except_match
    common_add_check_on_register("except", "bar", 0)
  end

  def test_add_check_on_register_except_no_match
    common_add_check_on_register("except", "dev", 1)
  end

  def test_add_check_on_register_except_no_tags
    common_add_check_on_register("except", "", 1, nil)
  end

  def test_update_check_config

    create_bundle("system/provisioning")
    create_bundle("system/monitoring")

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
        r = MultiJson.load(req.body)
        r["operation"] == "shell_exec" and r["params"]["command"] == "update_check_config.rb"
      }.
        to_return(:status => 200, :body => cmd_res_json())

    Provisioning.any_instance.expects(:provision).once.with { |agent, cmd|
      agent == @check.agent and cmd.kind_of?(Array) and cmd.size == 1 and cmd.first.bundle == @check.command.bundle.path
    }

    ret = Bixby::Monitoring.new.update_check_config(@check.agent)

    assert_requested(stub)
    assert_kind_of CommandResponse, ret

  end

  def test_alerting_on_metrics

    (m, t, a) = setup_trigger()

    # try again, this should generate an email
    put_check_result()

    assert_enqueued_jobs 1

    # check that history was recorded
    th = TriggerHistory.all
    refute_empty th
    assert_equal 1, th.size

    th = th.first
    assert th
    assert_equal t.id, th.trigger_id
    assert_equal 280, th.threshold

    # if we alert again, there should be no state change
    put_check_result()
    assert_enqueued_jobs 1
    assert_equal 1, TriggerHistory.all.size

    # now modify the alert so it returns to normal on next put
    t.threshold = 300
    t.save!

    put_check_result()
    assert_enqueued_jobs 2
    assert_equal 2, TriggerHistory.all.size

    th = TriggerHistory.last
    assert_equal t.id, th.trigger_id
    assert_equal 300, th.threshold
    assert_equal Trigger::Severity::OK, th.severity

    # make sure we don't alert again
    put_check_result()
    assert_enqueued_jobs 2
    assert_equal 2, TriggerHistory.all.size
  end

  def test_alerting_on_status
    setup_trigger()
    put_check_result("CRITICAL")
    assert_enqueued_jobs 1
    assert_equal 1, TriggerHistory.all.size
  end

  def test_alert_multiple_triggers
    (m, t, a)    = setup_trigger()
    (m2, t2, a2) = setup_trigger(m) # re-use metric for second trigger

    # now both triggers should fire which means 2 emails?
    put_check_result()
    assert_enqueued_jobs 2
    assert_equal 2, TriggerHistory.all.size

    # only the CRIT should fire when: metric=OK, WARN&CRIT triggers attached
    m.status = Metric::Status::OK
    m.save!
    t2.severity = Trigger::Severity::WARNING
    t2.save!

    put_check_result()
    assert_enqueued_jobs 3
    assert_equal 3, TriggerHistory.all.size
  end

  def test_get_options

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      r = MultiJson.load(req.body)
      rp = r["params"]
      r["operation"] == "shell_exec" and rp["args"] == "--options" and
        rp["command"] == @check.command.command and
        rp.include? "digest" and rp["digest"] =~ /^e5ece5285a7c759f/
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
        rp.include? "digest" and rp["digest"] =~ /^e5ece5285a7c759f/
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

  def put_check_result(status="OK")
    m = {
          "timestamp" => 1329775841,
          "metrics" => [
            {
              # create 4 Metrics
              "metrics"  => { "size"=>297, "used"=>202, "free"=>94, "usage"=>69 },
              "metadata" => { "mount"=>"/", "type"=>"hfs" }
            },
            {
              # will create another 4 Metrics with the same check_id
              "metrics"  => { "size"=>297, "used"=>202, "free"=>94, "usage"=>69 },
              "metadata" => { "mount"=>"/Volume/foobar", "type"=>"hfs" }
            }
          ],
          "errors"   => [],
          "status"   => status,
          "check_id" => @check.id,
          "key"      => "hardware.storage.disk"
    }

    Continuum::OpenTSDB.any_instance.expects(:metric).with { |n,v,t|
      n =~ /^hardware/ && t.to_i == 1329775841 }.times(8)

    Bixby::Metrics.new.put_check_result(m)
  end

  def setup_trigger(m=nil)

    # init metric data
    if m.nil? then
      put_check_result()
      m = Metric.where(:key => "hardware.storage.disk.size").first
      assert m
    end

    t = Trigger.new
    t.check_id = m.check_id
    t.metric = m
    t.severity = Trigger::Severity::CRITICAL
    t.threshold = 280
    t.sign = :gt
    t.status = %w{TIMEOUT CRITICAL}
    t.save!

    a = Action.new
    a.trigger_id = t.id
    a.action_type = Action::ALERT
    a.target_id = OnCall.first.id
    a.save!

    return [m, t, a]
  end

  def common_add_check_on_register(mode, tags, expected_size, host_tags="foo,bar")
    org = Org.first

    # create template
    ct = CheckTemplate.new(:name => "default", :mode => mode, :tags => tags, :org_id => org.id)
    ct.save!

    command = FactoryGirl.create(:command)
    cti = CheckTemplateItem.new
    cti.check_template_id = ct.id
    cti.command_id = command.id
    cti.save!

    Bixby::Scheduler.any_instance.expects(:schedule_at).with do |t, job|
      t = t.to_i # a bit of fudge on the time range
      (t >= Time.now.to_i+10 || t <= Time.now.to_i+11) && job.klass = Bixby::Inventory && job.method == :update_facts && job.args.first == Agent.last.host.id
    end

    if expected_size > 0 then
      Bixby::Scheduler.any_instance.expects(:schedule_at).with { |timestamp, job|
        t = Time.new.to_i + 15
        timestamp.to_i == t && job.method == :update_check_config && job.args.first == Agent.last.id
      }
    end

    ret = Bixby::Inventory.new.register_agent({
      :uuid => "foo", :public_key => "bar",
      :hostname => "foo.example.com",
      :tenant => org.tenant.name,
      :password => "test",
      :tags => host_tags,
      :version => "0.5.3"
      })

    assert ret
    assert_kind_of Hash, ret

    agent = Agent.last
    checks = Check.where(:host_id => agent.host_id)
    assert_equal expected_size, checks.size, "there should be #{expected_size} check(s)"
  end

end
end # Bixby
