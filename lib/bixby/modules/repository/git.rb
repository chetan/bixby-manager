
module Bixby
class Repository < API

  class GitRepo < BaseRepo
    def clone
      with_ssh do
        g = Git.clone(repo.uri, File.basename(repo.path), :path => File.dirname(repo.path))
        g.checkout(repo.branch) if !repo.branch.blank? && repo.branch != "master"
      end
    end

    def update
      with_ssh do
        g = Git.open(File.expand_path(repo.path), :log => log)
        g.pull("origin", "master")
      end
    end

    private

    def with_ssh(&block)
      if repo.private_key.blank? then
        return yield
      end

      git_ssh = ENV["GIT_SSH"]
      pk = Tempfile.new("bixby")
      ENV["GIT_SSH"] = File.join(File.expand_path(File.dirname(__FILE__)), "gitsshwrap.sh")
      ENV["GIT_SSH_BIXBY"] = pk.path

      begin
        File.chmod(0600, pk.path)
        pk.write(repo.private_key)
        pk.close

        return yield

      ensure
        pk.close
        pk.unlink

        ENV["GIT_SSH"] = ""
        ENV["GIT_SSH_BIXBY"] = ""
      end

    end
  end

end
end
