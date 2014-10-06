
class ScheduledCommandMailer < ActionMailer::Base

  def alert(scheduled_command, logs)
    @scheduled_command = scheduled_command
    @logs = logs

    cmd = scheduled_command.command
    if !cmd.name.blank? then
      @command_name = cmd.name
    else
      @command_name = "#{cmd.bundle.path}/bin/#{cmd.command}"
    end

    subject = "[Bixby] Scheduled Job: #{@command_name} -- "
    if logs.size == 1 then
      subject += logs.first.success? ? "SUCCES" : "FAIL"
    else
      pass = logs.count{ |l| l.success? }
      fail = logs.size - pass
      if pass == logs.size then
        subject += "SUCCES"
      else
        subject += "#{fail}/#{logs.size} FAILED"
      end
    end

    emails = []
    users = scheduled_command.get_alert_users
    if users then
      users.each{ |u| emails << u.email_address }
    end

    mail(:from    => BIXBY_CONFIG[:mailer_from],
         :to      => emails,
         :subject => subject)
  end


  class << self
    def num_bytes(str)
      return "0 bytes" if str.blank?

      s = "#{str.length} byte"
      s += "s" if str.length > 1
      s
    end

    def num_lines(str)
      return "0 lines" if str.blank?

      lines = str.split("\n")
      s = "#{lines.length} line"
      s += "s" if lines.length != 1
      s
    end
  end

end
