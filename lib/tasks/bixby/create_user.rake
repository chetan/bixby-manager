
require 'openssl'
require 'highline'

namespace :bixby do

  desc "create a new user"
  task :create_user => :environment do |t|

    puts "Create user"
    puts
    puts "available tenants:"
    Tenant.all.each { |t| puts t.name }
    puts

    h = HighLine.new
    tenant = h.ask("Tenant: ")
    if tenant.blank? then
      puts "tenant is required!"
      exit 1
    end
    tenant = Tenant.where(:name => tenant).first
    if tenant.blank? then
      puts "invalid tenant!"
      exit 1
    end

    name = h.ask("Name: ")
    if name.blank? then
      puts "name is required!"
      exit 1
    end

    username = h.ask("Username: ")
    email = h.ask("Email: ")
    pass = h.ask("Password: ") { |q| q.echo = "*" }

    exit 1 if name.blank? or pass.blank? or tenant.blank?
    Bixby::User.new.create_user(tenant, name, username, pass, email)
  end
end
