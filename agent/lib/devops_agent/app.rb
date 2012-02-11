
require 'devops_agent/server'
require 'devops_agent/cli'

class App

    include CLI

    def load_agent
        uri = @argv.empty? ? nil : @argv.shift
        root_dir = @config[:directory]
        port     = @config[:port]
        password = @config[:password]

        begin
            agent = Agent.create(uri, password, root_dir, port)
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
            agent = Agent.create(uri, password, root_dir, false)
        end
        if agent.new? then
            if (ret = agent.register_agent()).fail? then
                puts "error: failed to register with manager!"
                puts "reason:"
                puts "  #{ret.message}"
                exit(1)
            end
            agent.save_config()
        end
        agent
    end

    def setup_logger
        Logging::Logger.root.level = @config[:debug] ? :debug : :warn
        Logging::Logger.root.add_appenders(Logging.appenders.stdout)
    end

    def run!

        setup_logger()

        agent = load_agent()

        Server.agent = agent
        Server.set :port, agent.port
        Server.disable :protection
        # should probably just redirect these somewhere,
        # like "#{Agent.root}/logs/access|error.log"
        # Server.disable :logging
        # Server.disable :dump_errors

        Server.run!
    end

end
