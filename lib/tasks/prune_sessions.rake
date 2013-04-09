
namespace :maint do

  desc "Cleanup stale sessions (older than two weeks)"
  task :prune_sessions => :environment do
    Session.sweep!
  end

end
