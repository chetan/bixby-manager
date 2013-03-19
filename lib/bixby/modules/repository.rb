
module Bixby
class Repository < API

  VENDOR_URI = "https://github.com/chetan/bixby-repo.git"

  class << self

    # Get the list of rescan plugins
    #
    # @return [Array<Class>] List of rescan plugins
    def rescan_plugins
      @rescan_plugins ||= []
    end

  end # self

  # Update all configured repos (svn up or git pull) and rescan commands
  def update
    repos = Repo.all
    if repos.empty? then
      init_vendor_repo()
      return
    end

    repos.each do |repo|
      init_repo(repo)
      update_repo(repo)
      rescan_repo(repo)
    end

  end


  private

  def init_vendor_repo
    # puts "* initializing vendor repo"
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

    # puts "* initializing #{repo.path} from #{repo.uri}"

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
    logger = (RakeFileUtils.verbose_flag == true ? Logger.new(STDOUT) : nil)
    g = Git.open(repo.path, :log => logger)
    g.pull("origin", "origin/master")
  end

  def update_svn_repo(repo)
    raise NotImplementedError # TODO implement svn update
  end

  # Rescan a repo for new/updated Commands
  #
  # @param [Repo] repo
  def rescan_repo(repo)
    Rails.logger.info("* rescanning commands in #{repo.name} repository (#{repo.path})")
    Find.find(repo.path+"/") do |path|

      # skip everything except for /bin/ scripts in bundle dirs
      if File.basename(path) == ".git" then
        Find.prune
        next
      end
      if File.directory? path or path !~ /bin/ then
        next
      end

      # bin check
      rel_path = extract_rel_path(repo, path)
      paths = rel_path.split(%r{/})
      bundle = paths[0..1].join("/")
      paths = paths[2..paths.length]
      next if paths.shift != "bin"
      next if paths.last =~ /\.json$/

      # add it
      add_command(repo, bundle, paths.join("/"))
    end
  end

  # create or update the command
  def add_command(repo, bundle, script)
    Rails.logger.info("* found #{bundle} :: #{script}")

    cmds = Command.where("repo_id = ? AND bundle = ? AND command = ?", repo.id, bundle, script)
    if not cmds.blank? then
      cmd = cmds.first
      spec = cmd.to_command_spec
      if cmd.updated_at >= File.mtime(spec.command_file) and (!File.exists?(spec.config_file) or cmd.updated_at >= File.mtime(spec.config_file)) then
        Rails.logger.info "* skipping (not updated)"
        return
      end
      Rails.logger.info("* updating existing Command")
    else
      Rails.logger.info("* creating new Command")
      cmd = Command.new
      cmd.repo = repo
      cmd.bundle = bundle
      cmd.command = script
    end

    config = cmd.path + ".json"
    if File.exists? config then
      conf = MultiJson.load(File.read(config))
      cmd.name = conf["name"] || script
      cmd.options = conf["options"]
    else
      cmd.name = script
    end

    cmd.save!

    Repository.rescan_plugins.each do |plugin|
      plugin.update_command(cmd)
    end
  end

  def extract_rel_path(repo, str)
    str.gsub(/#{repo.path}/, '').gsub(/^\/?/, '')
  end

end # class Repository
end # Bixby
