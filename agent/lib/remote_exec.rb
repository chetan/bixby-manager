
require File.dirname(__FILE__) + "/command"
require File.dirname(__FILE__) + "/package_not_found"
require File.dirname(__FILE__) + "/command_not_found"

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
