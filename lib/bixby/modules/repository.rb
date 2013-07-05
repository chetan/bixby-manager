
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
      clone_repo(repo)
      update_repo(repo)
      rescan_repo(repo)
    end

  end


  private

  def init_vendor_repo
    r = Repo.new
    r.name = "vendor"
    r.uri = VENDOR_URI
    r.branch = "master"
    r.save!
    clone_repo(r)
  end

  def clone_repo(repo)
    if File.exists? repo.path then
      return
    end

    FileUtils.mkdir_p(repo.path)
    create_repo_wrapper(repo).clone()
  end

  def update_repo(repo)
    create_repo_wrapper(repo).update()
  end

  def create_repo_wrapper(repo)
    if repo.git? then
      GitRepo.new(repo)
    else
      SvnRepo.new(repo)
    end
  end

  # Rescan a repo for new/updated Commands
  #
  # @param [Repo] repo
  def rescan_repo(repo)
    log.info("* rescanning commands in #{repo.name} repository (#{repo.path})")
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
      next if paths.last =~ /\.(json|test.*)$/

      # add it
      add_command(repo, bundle, paths.join("/"))
    end
  end

  # create or update the command
  def add_command(repo, bundle, script)
    log.info("* found #{bundle} :: #{script}")

    cmds = Command.where("repo_id = ? AND bundle = ? AND command = ?", repo.id, bundle, script)
    if not cmds.blank? then
      cmd = cmds.first
      spec = cmd.to_command_spec
      if cmd.updated_at >= File.mtime(spec.command_file) and (!File.exists?(spec.config_file) or cmd.updated_at >= File.mtime(spec.config_file)) then
        log.info "* skipping (not updated)"
        return
      end
      log.info("* updating existing Command")
    else
      log.info("* creating new Command")
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

require "bixby/modules/repository/base"
require "bixby/modules/repository/git"
require "bixby/modules/repository/svn"
