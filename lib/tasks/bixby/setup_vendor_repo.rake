
namespace :bixby do

  desc "setup the vendor repo"
  task :setup_vendor_repo => :environment do |t, args|
    if not Repo.all.empty? then
      puts "nothing to do!"
      exit 1
    end

    r = Repo.new
    r.uri = "https://github.com/chetan/bixby-repo.git"
    r.name = "vendor"
    r.branch = "master"
    r.save!
  end

end
