
require "command"
require "exception/bundle_not_found"
require "exception/command_not_found"

require 'systemu'

module RemoteExec

    # params hash contains:
    #   repo
    #   bundle
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)
        cmd = Command.new(params)
        cmd.validate()
        return cmd.execute()
    end

end
