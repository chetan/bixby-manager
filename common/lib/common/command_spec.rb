
require 'util/jsonify'
require 'bundle_repository'

class CommandSpec

    include Jsonify

    attr_accessor :repo, :bundle, :command, :args, :env

    # params hash contains:
    #   repo
    #   bundle
    #   command
    #   args (optional)
    #   env (optional)
    def initialize(params = nil)
        return if params.nil? or params.empty?
        params.each{ |k,v| self.send("#{k}=", v) }
    end

    def to_hash
        { :repo => self.repo, :bundle => self.bundle, :command => self.command,
          :args => self.args, :env => self.env }
    end

    # returns triplet of [ status, stdout, stderr ]
    def execute
        puts @args
        cmd = "sh -c '#{self.command_file} #{@args}'"
        puts cmd
        status, stdout, stderr = systemu(cmd)
    end

    def validate
        if not bundle_exists? then
            raise BundleNotFound.new("repo = #{@repo}; bundle = #{@bundle}")
        end

        if not command_exists? then
            raise CommandNotFound.new("repo = #{@repo}; bundle = #{@bundle}; command = #{@command}")
        end
    end

    # resolve the given bundle
    def bundle_dir
        if @repo == "local" and Module.constants.include? "AGENT_ROOT" then
            # only resolve the special "local" repo for Agents
            return File.expand_path(File.join(AGENT_ROOT, "../../repo", @bundle))
        end
        File.join(BundleRepository.repository_path, @repo, @bundle)
    end

    def bundle_exists?
        File.exists? self.bundle_dir
    end

    def command_file
        File.join(self.bundle_dir, "bin", @command)
    end

    def command_exists?
        File.exists? self.command_file
    end

end
