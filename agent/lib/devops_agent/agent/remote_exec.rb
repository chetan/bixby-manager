
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
