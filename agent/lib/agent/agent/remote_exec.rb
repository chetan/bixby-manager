
require "common/command_spec"
require "common/exception/bundle_not_found"
require "common/exception/command_not_found"

require 'systemu'

module RemoteExec

    # params hash contains:
    #   repo
    #   bundle
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)
        cmd = CommandSpec.new(params)
        cmd.validate()
        return cmd.execute()
    end

end
