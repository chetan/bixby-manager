
# TODO
class MonitoringMailer < ActionMailer::Base

  def alert(metric, alert, user)
    @user = user
    @alert = alert
    @metric = metric

    mail(:to => user.email, :subject => "got a problem, boss")
  end
end
