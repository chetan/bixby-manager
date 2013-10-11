
class Rest::Models::CommandsController < ::Rest::ApiController

  def index
    type = params[:type]
    repo_id = _id(:repo, true)

    if type == "monitoring" then
      commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")
    elsif repo_id
      commands = Command.where(:repo_id => repo_id)
    else
      commands = Command.all
    end
    restful commands
  end

  def opts

    host    = Host.find(params[:host_id])
    command = Command.find(params[:command_id])

    begin
      if not command.options.blank? then
        opts = Bixby::Monitoring.new.get_command_options(host.agent, command)
        # merge retrieved opts into command.options
        opts.each { |k,v| command.options[k][:values] = v }
      end
    rescue Exception => ex
      if ex.message == "Curl::Err::ConnectionFailedError"
        msg = "Failed to contact agent (#{ex.message})"
      else
        msg = ex.message
      end
      command.options.keys.each do |opt|
        command.options[opt]["status"] = "failed"
        command.options[opt]["status_message"] = msg
      end

    end

    restful command
  end

end
