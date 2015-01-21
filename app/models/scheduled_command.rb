# ## Schema Information
#
# Table name: `scheduled_commands`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`org_id`**         | `integer`          |
# **`agent_ids`**      | `string(255)`      |
# **`command_id`**     | `integer`          |
# **`created_by`**     | `integer`          |
# **`stdin`**          | `text(65535)`      |
# **`args`**           | `text(65535)`      |
# **`env`**            | `text(65535)`      |
# **`schedule_type`**  | `integer`          |
# **`schedule`**       | `string(255)`      |
# **`scheduled_at`**   | `datetime`         |
# **`enabled`**        | `boolean`          | `default("1"), not null`
# **`job_id`**         | `string(255)`      |
# **`alert_on`**       | `integer`          | `default("0"), not null`
# **`alert_users`**    | `string(255)`      |
# **`alert_emails`**   | `text(65535)`      |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`completed_at`**   | `datetime`         |
# **`deleted_at`**     | `datetime`         |
# **`run_count`**      | `integer`          | `default("0"), not null`
#
# ### Indexes
#
# * `scheduled_commands_command_id_fk`:
#     * **`command_id`**
# * `scheduled_commands_created_by_fk`:
#     * **`created_by`**
# * `scheduled_commands_org_id_fk`:
#     * **`org_id`**
#

class ScheduledCommand < ActiveRecord::Base

  belongs_to :org
  belongs_to :agent
  belongs_to :command
  belongs_to :owner, :class_name => User, :foreign_key => :created_by

  has_many :command_logs

  include Bitfields
  bitfield :alert_on,
           1 => :alert_on_success,
           2 => :alert_on_error

  serialize :env, JSONColumn.new

  module ScheduleType
    CRON    = 1
    ONCE    = 2
    NATURAL = 2
  end
  Bixby::Util.create_const_map(ScheduleType)

  def self.for_user(user)
    where(:org_id => user.org.id)
  end

  def cron?
    self.schedule_type == ScheduleType::CRON
  end

  def once?
    self.schedule_type == ScheduleType::ONCE
  end

  # Updates scheduled_at with the time of the next run, for cron jobs only
  def update_next_run_time!
    if cron? then
      self.scheduled_at = CronParser.new(self.schedule).next()
    end
  end

  def command_spec
    spec = self.command.to_command_spec

    spec.args  = self.args
    spec.stdin = self.stdin
    spec.env   = self.env

    return spec
  end

  def agents
    Agent.where(:id => self.agent_ids.split(/,/).map{ |s| s.to_i })
  end

  def get_alert_users
    ids = self.alert_users.split(/,/).map{ |s| s.to_i }
    return nil if ids.blank?
    User.where(:id => ids)
  end

  # Schedules job to run at the designated time
  def schedule_job!
    job = Bixby::Scheduler::ScheduledCommandJob.create(self)
    self.job_id = Bixby::Scheduler.new.schedule_at(self.scheduled_at, job)
  end

  def cancel_job!
    Bixby::Scheduler.new.cancel(self.job_id)
    self.job_id = nil
    self.scheduled_at = nil
  end

  def enable!
    self.enabled = true
    update_next_run_time!
    schedule_job!
  end

  def disable!
    self.enabled = false
    cancel_job!
  end

end
