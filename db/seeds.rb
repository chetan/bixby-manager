# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

t = Tenant.create(:name => "pixelcop", :password => "098f6bcd4621d373cade4e832627b4f6")
o = Org.create(:name => "default", :tenant_id => t.id)
