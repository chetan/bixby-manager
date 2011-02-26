
module Provisioning

    def operation_dir(operation_name)
        agent_root + operation_name
    end

    def operation_script(operation_name)
        operation_dir(operation_name) + '/' + operation_name + '.rb'
    end

    def get_operation(operation_name)
        operation_script = operation_script(operation_name)
        if File.exist?(operation_script)
            return Operation.new(operation_script(operation_name))
        else
            return nil
        end
    end

    def provision_operation(operation_name)
        ret = http_get_json("http://#{manager_ip}:#{manager_port}/repo/fetch?name=#{operation_name}")
        url = ret['files'].first
        script = http_get(url)

        operation_dir = operation_dir(operation_name)
        operation_script = operation_script(operation_name)

        FileUtils.mkdir_p(operation_dir)
        File.open(operation_script, 'w') {|f| f.write(script)}
        `chmod 755 #{operation_script}`
    end

end
