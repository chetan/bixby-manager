# == Schema Information
#
# Table name: alert_histories
#
#  id               :integer          not null, primary key
#  alert_id         :integer          not null
#  user_notified_id :integer          not null
#  created_at       :datetime
#  check_id         :integer
#  metric_id        :integer
#  severity         :integer
#  threshold        :decimal(20, 2)
#  sign             :string(2)
#  value            :decimal(20, 2)
#


class AlertHistory < ActiveRecord::Base

  belongs_to :alert
  belongs_to :check
  belongs_to :metric

  multi_tenant :via => :check

  belongs_to :user_notified, :class_name => User

  def self.record(metric, alert, user)
    h = new()
    h.user_notified = user

    if alert.check.present? then
      h.check = alert.check
    else
      h.metric = metric
    end

    h.alert = alert
    h.severity = alert.severity
    h.threshold = alert.threshold
    h.sign = alert.sign

    h.value = metric.last_value
    h.save!
  end

end
