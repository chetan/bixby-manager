# ## Schema Information
#
# Table name: `agents`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`host_id`**       | `integer`          | `not null`
# **`uuid`**          | `string(255)`      |
# **`ip`**            | `string(16)`       |
# **`port`**          | `integer`          | `default(18000)`
# **`public_key`**    | `text`             |
# **`access_key`**    | `string(32)`       | `not null`
# **`secret_key`**    | `string(128)`      | `not null`
# **`status`**        | `integer`          | `default(0), not null`
# **`version`**       | `string(255)`      |
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`deleted_at`**    | `datetime`         |
# **`last_seen_at`**  | `datetime`         |
# **`is_connected`**  | `boolean`          | `default(FALSE)`
#
# ### Indexes
#
# * `fk_agents_hosts1`:
#     * **`host_id`**
#

require "semver"
require "bixby/util"

class Agent < ActiveRecord::Base

  belongs_to :host
  acts_as_paranoid
  multi_tenant :via => :host

  STATUS_NEW      = 0
  STATUS_ACTIVE   = 1
  STATUS_INACTIVE = 2

  # validations
  validates_presence_of :port, :uuid, :public_key
  validates_uniqueness_of :uuid, :public_key, :if => lambda { |a| a.new_record? }


  # Lookup an Agent by UUID
  #
  # @param [String] uuid      UUID to lookup
  #
  # @return [Agent] agent if found, or else nil
  def self.for_uuid(uuid)
    ret = where("uuid = ?", uuid)
    return ret.blank?() ? nil : ret.first
  end

  # Shortcut accessor for this Agent's Org
  #
  # @return [Org]
  def org
    self.host.org
  end

  def uri
    "http://#{self.ip}:#{self.port}/"
  end

  def semver
    return nil if version.blank?
    return SemVer.parse("v#{version}")
  end

end
