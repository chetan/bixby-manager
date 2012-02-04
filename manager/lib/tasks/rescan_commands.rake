
# rake devops:rescan_commands
# search repos for new commands

require 'find'

def log(str)
  return if not RakeFileUtils.verbose_flag
  puts str
end

def rescan_repo(repo)
  log("* rescanning commands in #{repo.name} repository (#{repo.path})")
  Find.find(repo.path) do |path|

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

    # add it
    add_command(repo, bundle, paths.join("/"))
  end
end

def add_command(repo, bundle, script)
  log("* found #{bundle} :: #{script}")
  return if not Command.where("repo_id = ? AND bundle = ? AND command = ?", repo.id, bundle, script).blank?

  # create new command
  log("* creating new Command")
  cmd = Command.new
  cmd.repo = repo
  cmd.bundle = bundle
  cmd.command = script
  cmd.save!
end

def extract_rel_path(repo, str)
  str.gsub(/#{repo.path}/, '').gsub(/^\/?/, '')
end

namespace :devops do

  desc "rescan commands in all repos"
  task :rescan_commands => :environment do
    require 'manager'
    require 'api/modules/base_module'
    require 'api/modules/bundle_repository'
    require 'modules/repository'

    Repo.all.each do |repo|
      rescan_repo(repo)
    end

  end
end

