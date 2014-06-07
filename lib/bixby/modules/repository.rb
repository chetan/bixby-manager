
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

  # Update all known repos (svn up or git pull), remove deleted commands and scan for new or
  # updated commands
  def update
    repos = Repo.all
    if repos.empty? then
      init_vendor_repo()
      return
    end

    repos.each do |repo|
      clone_repo(repo)
      update_repo(repo)
      verify_commands(repo)
      rescan_repo(repo)
      repo.touch # update timestamp
    end

  end


  # Create a new repository
  #
  # @param [Hash] opts
  # @option opts [Fixnum] org_id
  # @option opts [String] name
  # @option opts [String] uri
  # @option opts [String] branch
  # @option opts [Boolean] requires_key   Whether or not the repository (must be git) requires a public key
  #
  # @return [Repo]
  def create(opts)
    requires_key = opts.delete(:requires_key)
    r = Repo.new(opts)
    if r.branch.blank? then
      r.branch = r.git? ? "master" : "trunk"
    end

    if requires_key == true then
      pair = OpenSSL::PKey::RSA.generate(2048)
      r.private_key = pair.to_s
      r.public_key = pair.public_key.to_s
    end

    r.save!
    r
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
    log.info("updating repository #{repo.uri}")
    create_repo_wrapper(repo).update()
  end

  def create_repo_wrapper(repo)
    if repo.git? then
      GitRepo.new(repo)
    else
      SvnRepo.new(repo)
    end
  end

  # Rescan a repo for new/updated Bundles and Commands
  #
  # @param [Repo] repo
  def rescan_repo(repo)
    log.info("* rescanning commands in #{repo.name} repository (#{repo.path})")
    Find.find(repo.path+"/") do |path|

      # skip everything except for /bin/ scripts in bundle dirs
      filename = File.basename(path).downcase
      if filename == ".git" || filename == ".test" then
        Find.prune
        next
      end

      if filename == "manifest.json" then
        scan_bundle(repo, File.dirname(path))
        Find.prune
        next
      end

    end
  end

  # Scan the given bundle path
  #
  # @param [Repo] repo
  # @param [String] path
  def scan_bundle(repo, path)
    bundle_path = path[repo.path.length+1, path.length]
    bundle = Bundle.where(:repo_id => repo.id, :path => bundle_path).first
    if bundle.blank? then
      bundle         = Bundle.new
      bundle.repo_id = repo.id
      bundle.path    = bundle_path
    end
    bundle.digest = MultiJson.load(File.read(File.join(path, "digest")))["digest"]

    # add/update manifest info
    manifest_file = File.join(path, "manifest.json")
    if bundle.new_record? || bundle.updated_at > File.mtime(manifest_file) || bundle.name.blank? then
      manifest       = MultiJson.load(File.read(manifest_file))
      bundle.name    = manifest["name"]
      bundle.desc    = manifest["description"] || manifest["desc"]
      bundle.version = manifest["version"]
    end
    bundle.save

    # find the commands (bin/**)
    Dir.glob("#{path}/**/**") do |f|
      if File.directory?(f) or f !~ %r{/bin/} or f =~ /\.(json|test.*)$/ then
        next
      end

      # bin check
      rel_path = f.gsub(/^#{repo.path}/, '').gsub(/^\/?/, '')
      rel_path =~ %r{^(.*?)/bin/(.*)$}
      script = $2

      # add it
      add_command(repo, bundle, script)
    end
  end

  # Create or update a command
  #
  # @param [Repo] repo
  # @param [Bundle] bundle
  # @param [String] script
  def add_command(repo, bundle, script)
    log.info("* found #{bundle.path} :: #{script}")

    cmd = Command.where(:repo_id => repo.id, :bundle_id => [nil, bundle.id], :command => script).first
    if not cmd.blank? then
      spec = cmd.to_command_spec
      if cmd.updated_at and cmd.updated_at >= File.mtime(spec.command_file) and
          (!File.exists?(spec.config_file) or cmd.updated_at >= File.mtime(spec.config_file)) then

        log.info "* skipping (not updated)"
        return
      end
      log.info("* updating existing Command")

    else
      log.info("* creating new Command")
      cmd = Command.new
      cmd.repo = repo
      cmd.bundle_id = bundle.id
      cmd.command = script
    end

    config = cmd.path + ".json"
    if File.exists? config then
      conf = MultiJson.load(File.read(config))
      cmd.name     = conf["name"] || script
      cmd.desc     = conf["desc"]
      cmd.location = conf["location"]
      cmd.options  = conf["options"]
    else
      cmd.name = script
    end

    cmd.save!

    Repository.rescan_plugins.each do |plugin|
      plugin.update_command(cmd)
    end
  end

  # Verify that all known commands still exist. If not, soft-delete.
  #
  # @param [Repo] repo
  def verify_commands(repo)
    repo.commands.each do |cmd|
      next if !cmd.bundle
      if not File.exist? cmd.path then
        cmd.destroy!
      end
    end
  end

end # class Repository
end # Bixby

require "bixby/modules/repository/base"
require "bixby/modules/repository/git"
require "bixby/modules/repository/svn"
