# ## Schema Information
#
# Table name: `checks`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`host_id`**          | `integer`          | `not null`
# **`agent_id`**         | `integer`          | `not null`
# **`command_id`**       | `integer`          | `not null`
# **`args`**             | `text`             |
# **`normal_interval`**  | `integer`          |
# **`retry_interval`**   | `integer`          |
# **`timeout`**          | `integer`          |
# **`plot`**             | `boolean`          |
# **`enabled`**          | `boolean`          | `default(FALSE)`
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`deleted_at`**       | `datetime`         |
#
# ### Indexes
#
# * `checks_host_id_fk`:
#     * **`host_id`**
# * `fk_checks_agents1`:
#     * **`agent_id`**
# * `fk_checks_commands1`:
#     * **`command_id`**
#

class Check < ActiveRecord::Base

  belongs_to :host
  belongs_to :agent
  belongs_to :command

  has_many :metrics

  acts_as_paranoid
  multi_tenant :via => :host

  serialize :args, JSONColumn.new

  # Shortcut accessor for this Check's Org
  #
  # @return [Org]
  def org
    self.host.org
  end

  # Get a list of MetricInfo that this check provides
  def metric_infos
    @metric_infos ||= MetricInfo.where(:command_id => self.command_id)
  end

end
