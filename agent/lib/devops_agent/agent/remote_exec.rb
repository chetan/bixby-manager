
require 'systemu'

module RemoteExec

    # params hash contains:
    #   repo
    #   bundle
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)
        @log.debug{ "exec: #{params}" }
        cmd = CommandSpec.new(params)
        cmd.validate()
        ret = cmd.execute()
        @log.debug{ "ret: " + ret.to_json }
        return ret
    end

end
