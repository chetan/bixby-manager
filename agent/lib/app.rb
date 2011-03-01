
require File.dirname(__FILE__) + "/cli"

class App

    include CLI

    def run!

        uri = @argv.empty? ? nil : @argv.shift
        root_dir = @config[:directory]

        agent = Agent.create(uri, root_dir)
        if agent.new? then
            if agent.mac_changed? then
                agent.deregister_agent()
                agent = Agent.create(uri, root_dir, false)
            end
            agent.register_agent()
            agent.save_config()
        end

        # start the server
        require AGENT_ROOT + "/lib/server"
        Server.run!

    end

end
