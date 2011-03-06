
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





        operation_name = params[:operation]

        operation = agent.get_operation(operation_name)
        if operation == nil
            agent.provision_operation(operation_name)
            operation = agent.get_operation(operation_name)
        end

        if operation != nil
            operation.execute
        else
            "Unknown operation #{params[:operation]}"
        end

    end

end
