
require AGENT_ROOT + "/command"
require AGENT_ROOT + "/exception/package_not_found"
require AGENT_ROOT + "/exception/command_not_found"

require 'systemu'

module RemoteExec

    # params hash contains:
    #   repo
    #   package
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)
        cmd = Command.new(params)
        cmd.validate()
        return cmd.execute()
    end

end
