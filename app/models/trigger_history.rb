# ## Schema Information
#
# Table name: `trigger_histories`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`trigger_id`**  | `integer`          | `not null`
# **`created_at`**  | `datetime`         |
# **`check_id`**    | `integer`          |
# **`metric_id`**   | `integer`          |
# **`severity`**    | `integer`          |
# **`threshold`**   | `decimal(20, 2)`   |
# **`status`**      | `string(255)`      |
# **`sign`**        | `string(2)`        |
# **`value`**       | `decimal(20, 2)`   |
#
# ### Indexes
#
# * `trigger_histories_check_id_fk`:
#     * **`check_id`**
# * `trigger_histories_metric_id_fk`:
#     * **`metric_id`**
# * `trigger_histories_trigger_id_fk`:
#     * **`trigger_id`**
#

class TriggerHistory < ActiveRecord::Base

  belongs_to :trigger
  belongs_to :check
  belongs_to :metric

  multi_tenant :via => :check

  # Retrieve previous history record for the given trigger
  #
  # @param [Trigger] trigger
  #
  # @return [TriggerHistory]
  def self.previous_for_trigger(trigger)
    ret = where(:trigger_id => trigger.id).order("created_at DESC").limit(1)
    ret.blank? ? nil : ret.first
  end

  # Record the triggering event
  #
  # @param [Metric] metric
  # @param [Trigger] trigger
  #
  # @return [TriggerHistory] new history record
  def self.record(metric, trigger)
    h = new()

    if trigger.check.present? then
      h.check = trigger.check
    end
    h.metric = metric

    h.trigger = trigger
    h.severity = metric.ok? ? Trigger::Severity::OK : trigger.severity
    h.threshold = trigger.threshold
    h.sign = trigger.sign

    h.value = metric.last_value
    h.save!
    h
  end

end
