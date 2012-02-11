
module RemoteExec

  module Methods

    def exec(agent, command)

      ret = agent.run_cmd(create_spec(command))
      if ret.success? then
        return ret
      end

      if ret.success? or ret.code != 404 then
        # either success or an error we can't handle, return
        return ret
      end

      # try to provision it, then try again

      # try to provision it
      puts "bundle not found... "
      puts "going to provision it"


      pret = Provisioning.provision(agent, command)

      if not pret.success? then
        # failed to provision, bail out
        return pret # TODO raise err?
      end

      puts "provisioned successfully, running command again..."
      puts
      rret = agent.run_cmd(command)
      p rret
      puts rret.data["stdout"]
      return rret

    end

    def create_spec(command)
      command = command.to_command_spec if command.kind_of? Command
      return command
    end

  end

  class << self
    include Methods
  end

  def self.included(o)
    o.extend(Methods)
  end

end
