
# rake bixby:update_repos
# git pull / svn up all attached repositories

if defined?(Rails) then
  Rails.logger = Logger.new(STDOUT)
  if RakeFileUtils.verbose_flag == true then
    Rails.logger.level = Logger::INFO
  else
    Rails.logger.level = Logger::WARN
  end
end

namespace :bixby do

  desc "update repositories from upstream sources (git pull/svn up)"
  task :update_repos => :environment do
    require 'bixby/modules/repository'
    Bixby::Repository.update
  end
end
