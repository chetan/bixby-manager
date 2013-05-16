
require 'openssl'
require 'highline'

namespace :bixby do

  desc "create a new tenant"
  task :create_tenant => :environment do |t|

    puts "Create tenant"
    puts

    h = HighLine.new
    name = h.ask("Name: ")
    if name.blank? then
      puts "name is required!"
      exit 1
    end

    pass = h.ask("Password: ") { |q| q.echo = "*" }

    exit 1 if name.blank? or pass.blank?

    Bixby::User.new.create_tenant(name, pass)
  end
end
