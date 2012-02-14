
module RemoteExec

  module Methods

    def exec(agent, command)

      command = create_spec(command)

      ret = agent.run_cmd(command)
      if ret.success? then
        return ret
      end

      if ret.code != 404 then
        # error we can't handle, return
        return ret
      end

      # try to provision it, then try again
      pret = Provisioning.new.provision(agent, command)

      if not pret.success? then
        # failed to provision, bail out
        return pret # TODO raise err?
      end

      return agent.run_cmd(command)
    end

    def create_spec(command)
      command = command.to_command_spec if command.kind_of? Command
      return command
    end

  end

  class << self
    include Methods
  end

  include Methods

end
