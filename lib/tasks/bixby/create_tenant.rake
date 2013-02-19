
require 'openssl'

namespace :bixby do

  desc "create a new tenant"
  task :create_tenant, [:name, :password] => :environment do |t, args|

    if args[:name].blank? or args[:password].blank? then
      puts "usage: rake bixby:create_tenant[name]"
      exit 1
    end

    Bixby::User.new.create_tenant(args[:name], args[:password])
  end
end
