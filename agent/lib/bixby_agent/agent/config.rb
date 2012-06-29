
require 'yaml'
require 'fileutils'

module Bixby
class Agent

module Config

  module ClassMethods

    def config_dir
      File.join(self.agent_root, "etc")
    end

    def config_file
      File.join(config_dir, "devops.yml")
    end

    def load_config(root_dir)
      self.agent_root = (root_dir.nil? ? (ENV["BIXBY_HOME"] || Agent::DEFAULT_ROOT_DIR) : root_dir)
      return nil if not File.exists? config_file

      # load it!
      begin
        agent = YAML.load_file(config_file)
        if not agent.kind_of? Agent then
          bad_config("corrupted file contents")
        end
        agent.new = false
        agent.log = Logging.logger[agent]
        return agent
      rescue Exception => ex
        if ex.kind_of? SystemExit then
          raise ex
        end
        bad_config(ex) if ex.message != "exit"
      end
    end

    def bad_config(ex = nil)
      # TODO should force a reinstall/handshake?
      puts "error loading config from #{config_file}"
      puts "(#{ex})" if ex
      puts "exiting"
      exit
    end

  end # ClassMethods

  def self.included(clazz)
    clazz.extend(ClassMethods)
  end

  def new=(val)
    @new = val
  end

  def new?
    @new
  end

  def config_dir
    self.class.config_dir
  end

  def config_file
    self.class.config_file
  end

  def init_config_dir
    if not File.exists? config_dir then
      begin
        FileUtils.mkdir_p(config_dir)
      rescue Exception => ex
        raise IOError.new(ex.message)
      end
    end
  end

  def save_config
    init_config_dir()
    File.open(config_file, 'w') { |out| out.write(self.to_yaml) }
  end

  def to_yaml_properties
    [ "@port", "@manager_uri", "@uuid", "@mac_address" ]
  end

end # Config

end # Agent
end # Bixby
