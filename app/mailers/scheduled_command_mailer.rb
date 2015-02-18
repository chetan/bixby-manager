
class ScheduledCommandMailer < ActionMailer::Base

  include Roadie::Rails::Automatic
  layout "mailer_base"

  module Helpers
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

    def out(log, sym)
      str = log.send(sym.to_sym)
      s = "#{sym.to_s.upcase}: (#{num_bytes(str)}, #{num_lines(str)})"
      s += "\n" + ("-"*s.length)
      s += str.blank? ? "" : "\n" + str
      s += "\n--EOF--"
      s
    end

    def env(sep=", ")
      env = @scheduled_command.env
      if env.blank? then
        "n/a"
      else
        env.keys.map { |k| "#{k}=#{env[k]}" }.join(sep)
      end
    end

    def stdin
      if @scheduled_command.stdin.blank? then
        "n/a"
      else
        "\n" + ("-"*30) + @scheduled_command.stdin + "\n--EOF--"
      end
    end

    def total_time_taken
      if @total_elapsed < 60 then
        sprintf("%0.2f", @total_elapsed) + " sec"
      else
        ChronicDuration.output(@total_elapsed.to_i, :short)
      end
    end
  end

  helper Helpers

  # @param [ScheduledCommand] scheduled_command
  # @param [Array<CommandLog>] logs
  # @param [Time] time_scheduled             time job was scheduled for
  # @param [Time] time_start                 time job was actually started
  # @param [Float] total_elapsed             elapsed time
  def alert(scheduled_command, logs, time_scheduled, time_start, total_elapsed)
    @scheduled_command = scheduled_command
    @logs = logs
    @time_scheduled = time_scheduled
    @time_start = time_start
    @total_elapsed = total_elapsed

    cmd = scheduled_command.command
    @script = "#{cmd.bundle.path}/bin/#{cmd.command}"
    @command_name = !cmd.name.blank? ? cmd.name : @script

    subject = "[Bixby] Scheduled Job: #{@command_name} -- "
    if logs.size == 1 then
      subject += logs.first.success? ? "SUCCESS" : "FAIL"
    else
      pass = logs.count{ |l| l.success? }
      fail = logs.size - pass
      if pass == logs.size then
        subject += "SUCCESS"
      else
        subject += "#{fail}/#{logs.size} FAILED"
      end
    end

    emails = []
    users = scheduled_command.get_alert_users
    if users then
      users.each{ |u| emails << u.email_address }
    end
    if !scheduled_command.alert_emails.blank? then
      emails += scheduled_command.alert_emails.split(/,/)
    end

    mail(:from    => BIXBY_CONFIG[:mailer_from],
         :to      => emails,
         :subject => subject)
  end

end
