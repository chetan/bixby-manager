
require 'bixby_agent/server'
require 'bixby_agent/cli'

module Bixby
class App

  include CLI

  def load_agent
    uri = @argv.empty? ? nil : @argv.shift
    root_dir = @config[:directory]
    port     = @config[:port]
    password = @config[:password]

    if @config[:debug] then
      puts "crypto disabled due to --debug flag"
      ENV["BIXBY_NOCRYPTO"] = "1"
    end

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
    level = @config[:debug] ? :debug : :warn
    Logging.appenders.stdout(
      :level  => level,
      :layout => Logging.layouts.pattern(:pattern => '[%d] %-5l: %m\n')
      )
    Logging::Logger.root.add_appenders(Logging.appenders.stdout)
    Logging::Logger.root.level = level
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

end # App
end # Bixby
