
namespace :devops do

  desc "update repositories"
  task :update_repos => :environment do
    require 'manager'
    require 'api/modules/base_module'
    require 'api/modules/bundle_repository'
    require 'modules/bundle_repository'

    BundleRepository.update!

  end
end

