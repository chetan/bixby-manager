
class Monitoring::CommandsController < Monitoring::BaseController

  def index
    @commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")

    respond_with(@commands.to_api)
  end

  def opts

    host    = Host.find(params[:host_id])
    command = Command.find(params[:command_id])

    if not command.options.blank? then
      opts = Bixby::Monitoring.new.get_command_options(host.agent, command)
      # merge retrieved opts into command.options
      opts.each { |k,v| command.options[k][:values] = v }
    end

    respond_with(command.to_api)
  end

end
