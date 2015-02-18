
class ScheduledCommandPreview < ActionMailer::Preview

  def cron_job
    ScheduledCommandMailer.alert(*create_args())
  end

  def one_time_job
    scheduled_command, *args = create_args()
    scheduled_command.schedule_type = 2
    scheduled_command.schedule      = nil
    scheduled_command.scheduled_at  = Time.new
    scheduled_command.run_count     = 1
    ScheduledCommandMailer.alert(scheduled_command, *args)
  end

  def cron_job_one_fail
    scheduled_command, logs, *args = create_args()
    logs.first.status = 1
    ScheduledCommandMailer.alert(scheduled_command, logs, *args)
  end

  private

  def create_args
    command = Command.where(:name => "Hello World!").first
    scheduled_command = ScheduledCommand.new({
      :org_id        => Org.first.id,
      :agent_ids     => Agent.all.map{ |a| a.id }.join(","),
      :command_id    => command.id,
      :created_by    => User.first.id,
      :args          => "foobar",
      :env           => {"TEST" => "baz", "DEBUG" => "1"},
      :schedule_type => 1,
      :schedule      => "*/5 * * * * *",
      :alert_on      => 3,
      :alert_users   => User.first.id.to_s,
      :alert_emails  => "foobar@example.com",
      :created_at    => Time.new,
      :updated_at    => Time.new,
      :run_count     => 3
      })
    scheduled_command.update_next_run_time!

    agents = Agent.all.to_a
    agents << Agent.new({
      :host => Host.new(:alias => "mailer test host")
      })

    logs = []
    agents.each do |agent|
      logs << CommandLog.new({
        :org_id       => Org.first.id,
        :user_id      => User.first.id,
        :agent_id     => agent.id,
        :agent        => agent,
        :command_id   => command.id,
        :run_id       => 3,
        :exec_status  => true,
        :status       => 0,
        :stdout       => "Hello world!",
        :requested_at => Time.new,
        :time_taken   => 0.15
        })
    end

    time_scheduled = Time.new.utc-1
    time_start = Time.new.utc
    total_elapsed = 0.27

    return [scheduled_command, logs, time_scheduled, time_start, total_elapsed]
  end

end
