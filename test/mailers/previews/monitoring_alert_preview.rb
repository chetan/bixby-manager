
# begin
#   require File.join(Rails.root, "test", "factories")
# rescue FactoryGirl::DuplicateDefinitionError
# end

class MonitoringAlertPreview < ActionMailer::Preview

  def alert
    transaction do
      user = User.first
      metric = Metric.where("updated_at > ?", Time.new-86400*7).first
      alert = Trigger.new(
        :check_id => metric.check.id, :metric_id => metric.id,
        :severity => Trigger::Severity::WARNING, :threshold => 50, :sign => :gt)
      alert.status = %w{ WARNING UNKNOWN TIMEOUT }

      MonitoringMailer.alert(metric, alert, user)
    end
  end


  private

  def transaction
    ret = nil
    ActiveRecord::Base.transaction do
      ret = yield
      ActiveRecord::Base.connection.rollback_db_transaction
    end
    ret
  end

end
