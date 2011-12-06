
class BundleRepository

  VENDOR_URI = "https://github.com/chetan/devops_repo.git"

  class << self

    def update!
      repos = Repo.all
      if repos.empty? then
        init_vendor_repo()
        return
      end

      repos.each do |repo|
        init_repo(repo)
        update_repo(repo)
      end

    end



    private

    def init_vendor_repo
      puts "* initializing vendor repo"
      r = Repo.new
      r.name = "vendor"
      r.uri = VENDOR_URI
      r.branch = "master"
      r.save!
      init_repo(r)
    end

    def init_repo(repo)

      if File.exists? repo.path then
        return
      end

      puts "* initializing #{repo.path} from #{repo.uri}"

      FileUtils.mkdir_p(repo.path)
      if repo.git? then
        init_git_repo(repo)
      else
        init_svn_repo(repo)
      end

    end

    def init_git_repo(repo)
      g = Git.clone(repo.uri, File.basename(repo.path), :path => File.dirname(repo.path))
      g.checkout(repo.branch) if not repo.branch == "master"
    end

    def init_svn_repo(repo)
      raise NotImplementedError # TODO implement svn checkout
    end

    def update_repo(repo)
      if repo.git? then
        update_git_repo(repo)
      else
        update_svn_repo(repo)
      end
    end

    def update_git_repo(repo)
      g = Git.open(repo.path)
      g.pull
    end

    def update_svn_repo(repo)
      raise NotImplementedError # TODO implement svn update
    end

  end
end
