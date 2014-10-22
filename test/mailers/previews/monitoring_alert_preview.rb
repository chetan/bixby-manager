
# begin
#   require File.join(Rails.root, "test", "factories")
# rescue FactoryGirl::DuplicateDefinitionError
# end

class MonitoringAlertPreview < ActionMailer::Preview

  def alert
    metric = Metric.where("updated_at > ?", Time.new-86400*7).first
    send_alert(metric, 78.32, 70, :gt)
  end

  def alert_cpu_load
    metric = Metric.where("`key` = ? AND updated_at > ?", "cpu.loadavg.1m", Time.new-86400*7).first
    send_alert(metric, 3.48, 3.0, :ge)
  end


  private

  def send_alert(metric, val, threshold, sign=:gt)
    transaction do
      user = User.first
      metric.last_value = val

      alert = Trigger.new(
        :check_id  => metric.check.id,
        :metric_id => metric.id,
        :severity  => Trigger::Severity::WARNING,
        :sign      => sign,
        :threshold => threshold)
      alert.status = %w{ WARNING UNKNOWN TIMEOUT }

      MonitoringMailer.alert(metric, alert, user)
    end
  end

  def transaction
    ret = nil
    ActiveRecord::Base.transaction do
      ret = yield
      ActiveRecord::Base.connection.rollback_db_transaction
    end
    ret
  end

end
