
class MonitoringMailer < ActionMailer::Base
  default :from => "bixby@fw2.net"

  def alert(metric, alert, user)
    @user = user
    @alert = alert
    @metric = metric

    mail(:to => user.email, :subject => "got a problem, boss")
  end
end
