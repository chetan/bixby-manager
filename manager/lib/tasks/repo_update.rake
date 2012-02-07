
# rake devops:update_repos
# git pull / svn up all attached repositories

namespace :devops do

  desc "update repositories from upstream sources (git pull/svn up)"
  task :update_repos => :environment do
    require 'manager'
    require 'modules/repository'

    Repository::BundleRepository.update

  end
end

