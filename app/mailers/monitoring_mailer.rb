
# TODO
class MonitoringMailer < ActionMailer::Base

  def alert(metric, alert, user)
    @user = user
    @alert = alert
    @metric = metric

    mail(:from => BIXBY_CONFIG[:mailer_from],
         :to => user.email,
         :subject => "got a problem, boss")
  end
end
