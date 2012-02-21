
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

        digest = params["digest"] || params[:digest]
        if digest and cmd.digest != digest then
            raise BundleNotFound, "digest does not match", caller
        end
        ret = cmd.execute()
        @log.debug{ "ret: " + ret.to_json }
        return ret
    end

end
