# == Schema Information
#
# Table name: trigger_histories
#
#  id               :integer          not null, primary key
#  trigger_id       :integer          not null
#  action_type      :integer          not null
#  action_target_id :integer          not null
#  action_args      :text
#  created_at       :datetime
#  check_id         :integer
#  metric_id        :integer
#  severity         :integer
#  threshold        :decimal(20, 2)
#  status           :string(255)
#  sign             :string(2)
#  value            :decimal(20, 2)
#


class TriggerHistory < ActiveRecord::Base

  belongs_to :trigger
  belongs_to :check
  belongs_to :metric

  multi_tenant :via => :check

  belongs_to :user_notified, :class_name => User

  def self.record(metric, trigger, user)
    h = new()
    h.user_notified = user

    if trigger.check.present? then
      h.check = trigger.check
    else
      h.metric = metric
    end

    h.trigger = trigger
    h.severity = trigger.severity
    h.threshold = trigger.threshold
    h.sign = trigger.sign

    h.value = metric.last_value
    h.save!
  end

end
