# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

config = YAML.load_file(File.open(File.join(::Rails.root.to_s, "config", "bixby.yml")))[Rails.env]
t = Tenant.create(
  :name        => config["default_tenant"],
  :password    => SCrypt::Password.create(config["default_tenant_pw"]).to_s,
  :private_key => OpenSSL::PKey::RSA.generate(2048).to_s
  )

o = Org.create(:name => "default", :tenant_id => t.id)
r = Repo.create(:org_id => nil, :name => "vendor",
      :uri => "https://github.com/chetan/bixby-repo.git",
      :branch => "master")

u = User.create(
  :org_id                => o.id,
  :name                  => t.name,
  :username              => t.name,
  :email                 => "test@example.com"
)

# password is a virtual field used by authlogic, so set this after
u.password              = config["default_tenant_pw"]
u.password_confirmation = config["default_tenant_pw"]
u.save!
