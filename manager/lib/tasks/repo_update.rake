
# rake devops:update_repos
# git pull / svn up all attached repositories

namespace :devops do

  desc "update repositories from upstream sources (git pull/svn up)"
  task :update_repos => :environment do
    require 'manager'
    require 'api/modules/base_module'
    require 'api/modules/bundle_repository'
    require 'modules/bundle_repository'

    BundleRepository.update!

  end
end

