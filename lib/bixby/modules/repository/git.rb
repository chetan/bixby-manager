
module Bixby
class Repository < API

  class GitRepo < BaseRepo
    def clone
      g = Git.clone(repo.uri, File.basename(repo.path), :path => File.dirname(repo.path))
      g.checkout(repo.branch) if not repo.branch == "master"
    end

    def update
      g = Git.open(repo.path, :log => log)
      g.pull("origin", "origin/master")
    end
  end

end
end
