
class Rest::Models::CommandsController < Rest::BaseController

  def index
    type = params[:type]
    repo_id = _id(:repo, true)

    if type == "monitoring" then
      Command.for_monitoring(current_user)
    elsif repo_id
      Command.for_repos(repo_id)
    else
      Command.all.for_user(current_user)
    end
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
        # TODO this shouldn't come up anymore
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

  def run
    hosts   = params[:hosts].map{ |s| s.to_i }.reject{ |s| s <= 0 }
    agents  = Agent.where(:host_id => hosts)
    command = Command.find(_id(:command_id)).to_command_spec

    command.args  = params[:args]   if !params[:args].blank?
    command.stdin = params[:stdin]  if !params[:stdin].blank?
    command.env   = params[:env]    if !params[:env].blank?

    results = {}
    agents.each do |agent|
      results[agent.host_id] = Bixby::RemoteExec.new(request, nil, current_user).exec(agent, command).log
    end

    # write responses for invalid agents
    hosts.each do |host_id|
      if not results.include? host_id then
        log              = CommandLog.new
        log.command      = Command.from_command_spec(command)
        log.user         = current_user
        log.exec_status  = false
        log.exec_code    = -1
        log.status       = -1
        log.stdout       = nil
        log.stderr       = "[FATAL] Agent not found for host"
        log.requested_at = Time.new
        log.time_taken   = 0

        results[host_id] = log
      end
    end

    restful results
  end

end
