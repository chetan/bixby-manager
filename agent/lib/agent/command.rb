
class Command

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

    # returns triplet of [ status, stdout, stderr ]
    def execute
        status, stdout, stderr = systemu("sh -c '#{self.command_file} #{@args}'")
    end

    def validate
        if not bundle_exists? then
            raise BundleNotFound.new("repo = #{@repo}; bundle = #{@bundle}")
        end

        if not command_exists? then
            raise CommandNotFound.new("repo = #{@repo}; bundle = #{@bundle}; command = #{@command}")
        end
    end

    def bundle_dir
        File.join(Agent.agent_root, "repo", @repo, @bundle)
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
