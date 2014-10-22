
class MonitoringMailer < ActionMailer::Base

  layout "mailer_base"

  def alert(metric, trigger, user)
    @user    = user
    @trigger = trigger
    @metric  = metric
    @info    = metric.info
    @unit    = @info && @info.unit ? @info.unit : ""

    @command = metric.check.command

    manifest = @command.to_command_spec.manifest
    @help = {
      :text => manifest["help"],
      :url  => manifest["help_url"]
    }

    subject = "[Bixby] #{trigger.severity_to_s}: #{@command.display_name} is #{trigger.sign_to_s} #{trigger.threshold}"

    mail(
      :from    => BIXBY_CONFIG[:mailer_from],
      :to      => user.email_address,
      :subject => subject
      )
  end
end
