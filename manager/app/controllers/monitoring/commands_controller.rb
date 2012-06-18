
class Monitoring::CommandsController < Monitoring::BaseController

  def index
    @commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")
    restful @commands
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
      command.options.keys.each do |opt|
        command.options[opt] = [ "failed" ]
      end

    end

    restful command
  end

end
