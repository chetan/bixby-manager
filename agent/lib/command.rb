
class Command

    attr_accessor :repo, :package, :command, :args, :env

    # params hash contains:
    #   repo
    #   package
    #   command
    #   args (optional)
    #   env (optional)
    def initialize(params)
        params.each{ |k,v| self.send("#{k}=", v) }
    end

    # returns triplet of [ status, stdout, stderr ]
    def execute
        status, stdout, stderr = systemu("sh -c '#{self.command_file} #{@args}'")
    end

    def validate
        if not package_exists? then
            raise PackageNotFound.new("repo = #{@repo}; package = #{@package}")
        end

        if not command_exists? then
            raise CommandNotFound.new("repo = #{@repo}; package = #{@package}; command = #{@command}")
        end
    end

    def package_dir
        File.join(Agent.agent_root, "repo", @repo, @package)
    end

    def package_exists?
        File.exists? self.package_dir
    end

    def command_file
        File.join(self.package_dir, "bin", @command)
    end

    def command_exists?
        File.exists? self.command_file
    end

end
