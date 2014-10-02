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
# **`agent_id`**       | `integer`          |
# **`command_id`**     | `integer`          |
# **`created_by`**     | `integer`          |
# **`stdin`**          | `text`             |
# **`args`**           | `text`             |
# **`env`**            | `text`             |
# **`schedule_type`**  | `integer`          |
# **`schedule`**       | `string(255)`      |
# **`scheduled_at`**   | `datetime`         |
# **`alert_on`**       | `integer`          | `default(0), not null`
# **`alert_users`**    | `string(255)`      |
# **`alert_emails`**   | `text`             |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`completed_at`**   | `datetime`         |
# **`deleted_at`**     | `datetime`         |
#
# ### Indexes
#
# * `scheduled_commands_agent_id_fk`:
#     * **`agent_id`**
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
  belongs_to :user, :foreign_key => :created_by
  belongs_to :command_log

  module ScheduleType
    CRON = 1
    ONCE = 2
  end
  Bixby::Util.create_const_map(ScheduleType)

end
