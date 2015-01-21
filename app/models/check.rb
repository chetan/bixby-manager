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
# **`args`**             | `text(65535)`      |
# **`normal_interval`**  | `integer`          |
# **`retry_interval`**   | `integer`          |
# **`timeout`**          | `integer`          |
# **`plot`**             | `boolean`          |
# **`enabled`**          | `boolean`          | `default("0")`
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

require "rails_ext"

class Check < ActiveRecord::Base

  belongs_to :host
  belongs_to :agent
  belongs_to :command

  has_many :metrics, :inverse_of => :check
  has_many :metric_infos, :through => :command

  acts_as_paranoid
  multi_tenant :via => :host

  serialize :args, JSONColumn.new

  # Shortcut accessor for this Check's Org
  #
  # @return [Org]
  def org
    self.host.org
  end

end
