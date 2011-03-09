
require File.dirname(__FILE__) + "/package_not_found"

require 'systemu'

module RemoteExec

    def package_dir(repo, package)
        File.join(self.agent_root, "repo", repo, package)
    end

    def package_exists?(repo, package)
        File.exists? self.package_dir(repo, package)
    end

    def run_command(cmd, args, env = nil)
        status, stdout, stderr = systemu("#{cmd} #{args}")
    end

    # params hash contains:
    #   package
    #   command
    #   args (optional)
    #   env (optional)
    def exec(params)

        if not package_exists?(params["repo"], params["package"]) then
            raise PackageNotFound.new("repo = #{params["repo"]}; package = #{params["package"]}")
        end

        return run_command(params["command"], params["args"])

    end

end
