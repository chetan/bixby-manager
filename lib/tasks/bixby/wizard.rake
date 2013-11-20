
namespace :bixby do

  desc "run bixby setup wizard"
  task :wizard => :environment do |t|

    disable_logging!

    puts "Welcome to Bixby!"
    puts
    puts "This wizard will run the following tasks for you:"
    puts "* Setup the default vendor repository"
    puts "* Create a tenant"
    puts "* Create a user"
    puts

    Rake::Task["bixby:update_repos"].invoke
    puts "Created vendor repo"
    puts

    Rake::Task["bixby:create_tenant"].invoke
    puts
    puts
    Rake::Task["bixby:create_user"].invoke

    # insert repo update job
    job = Bixby::Scheduler::RecurringJob.create(1.hour, Bixby::Repository, :update)
    Bixby::Scheduler.new.schedule_in(1.hour, job)

    puts "Done! You can now start the server and login"
  end
end
