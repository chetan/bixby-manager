
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

        digest = params.delete("digest") || params.delete(:digest)

        cmd = CommandSpec.new(params)
        cmd.validate()
        if digest and cmd.digest != digest then
            raise BundleNotFound, "digest does not match", caller
        end

        ret = cmd.execute()
        @log.debug{ "ret: " + ret.to_json }
        return ret
    end

end
