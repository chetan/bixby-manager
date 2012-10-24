
class AlertHistory < ActiveRecord::Base

  belongs_to :alert
  belongs_to :check
  belongs_to :metric

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
