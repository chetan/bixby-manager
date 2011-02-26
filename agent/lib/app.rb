
class App

    def self.run!

        agent = Agent.create
        if agent.new? then
            if agent.mac_changed? then
                agent.deregister_agent()
                agent = Agent.create(false)
            end
            agent.register_agent()
            agent.save_config()
        end

        # start the server
        require AGENT_ROOT + "/lib/server"
        Server.run!

    end

end
