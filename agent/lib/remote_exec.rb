
require 'systemu'

module RemoteExec

    def package_exists?(package)
        true
    end

    def run_command(cmd, args, env = nil)
        status, stdout, stderr = systemu("#{cmd} #{args}")
    end

    # params hash contains:
    #   package
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)

        if not package_exists? params["package"] then
            # TODO return error
        end

        return run_command(params["command"], params["args"])

    end

end
