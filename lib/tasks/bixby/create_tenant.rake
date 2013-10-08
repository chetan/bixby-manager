
namespace :bixby do

  desc "create a new tenant"
  task :create_tenant => :environment do |t|

    disable_logging!

    require 'highline'

    puts "Create tenant"
    puts

    h = HighLine.new
    begin
      name = h.ask("Name: ")
    rescue Interrupt => ex
      exit 1
    end
    if name.blank? then
      puts "name is required!"
      exit 1
    end

    pass = h.ask("Password: ") { |q| q.echo = "*" }

    exit 1 if name.blank? or pass.blank?

    Bixby::User.new.create_tenant(name, pass)

  end
end
