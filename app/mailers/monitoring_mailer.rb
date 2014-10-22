
class MonitoringMailer < ActionMailer::Base

  def alert(metric, alert, user)
    @user = user
    @alert = alert
    @metric = metric

    @command = metric.check.command

    subject = "[Bixby] " + alert.severity_to_s + ": #{@command.display_name} is "
    subject += " #{alert.sign_to_s} #{alert.threshold}"

    mail(
      :from    => BIXBY_CONFIG[:mailer_from],
      :to      => user.email_address,
      :subject => subject
      )
  end
end
