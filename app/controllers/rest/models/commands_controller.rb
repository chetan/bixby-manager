
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
      results[agent.host_id] = Bixby::RemoteExec.new(request, nil, current_user).exec(agent, command)
    end

    # write responses for invalid agents
    hosts.each do |host_id|
      if not results.include? host_id then
        cr = Bixby::CommandResponse.new
        cr.status = -1
        cr.stdout = nil
        cr.stderr = "[FATAL] Agent not found for host"

        cr.log = CommandLog.new
        cr.log.user         = current_user
        cr.log.exec_status  = false
        cr.log.exec_code    = -1
        cr.log.requested_at = Time.new
        cr.log.time_taken   = 0
        results[host_id]    = cr
      end
    end

    restful results
  end

end
