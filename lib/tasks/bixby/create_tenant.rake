
require 'openssl'

namespace :bixby do

  desc "create a new tenant"
  task :create_tenant, [:name, :password] => :environment do |t, args|

    if args[:name].blank? or args[:password].blank? then
      puts "usage: rake bixby:create_tenant[name]"
      exit 1
    end

    # TODO dupe name check

    t = Tenant.new
    t.name = args[:name]
    t.password = Digest::MD5.new.hexdigest(args[:password])
    t.private_key = OpenSSL::PKey::RSA.generate(2048).to_s
    t.save!

    o = Org.new
    o.tenant = t
    o.name = "default"
    o.save!

  end
end
