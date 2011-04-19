
require AGENT_ROOT + "/cli"

class App

    include CLI

    def load_agent
        uri = @argv.empty? ? nil : @argv.shift
        root_dir = @config[:directory]

        begin
            agent = Agent.create(uri, root_dir)
        rescue Exception => ex
           if ex.message == "Missing manager URI" then
               # if unable to load from config and no uri passed, bail!
               puts "manager uri is required the first time you call me!"
               puts "usage: agent.rb [-d root dir] <manager uri>"
               exit
           end
           raise ex
        end

        if not agent.new? and agent.mac_changed? then
            # loaded from config and mac has changed
            agent.deregister_agent()
            agent = Agent.create(uri, root_dir, false)
        end
        if agent.new? then
            agent.register_agent()
            agent.save_config()
        end
        agent
    end

    def run!

        agent = load_agent()

        require AGENT_ROOT + "/server"
        Server.agent = agent
        Server.run!

    end

end
