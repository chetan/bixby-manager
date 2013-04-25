

namespace :db do
  desc "connect to the db console"
  task :console do
    conf = YAML.load(File.open(File.join(::Rails.root.to_s, "config", "database.yml")))
    conf = conf[Rails.env].with_indifferent_access

    if conf[:adapter] =~ /mysql/ then
      cmd = %w{mysql}
      cmd << "-h" + (conf[:host] ? conf[:host] : "localhost")
      cmd << "-u" + (conf[:username] ? conf[:username] : "root")
      cmd << "-p" if conf[:password]
      cmd << conf[:database]
    elsif conf[:adapter] == "postgresql" then
      cmd = %w{psql}
      cmd << "-h"
      cmd << (conf[:host] ? conf[:host] : "localhost")
      cmd << "-U"
      cmd << (conf[:username] ? conf[:username] : "root")
      cmd << "-W" if conf[:password]
      cmd << conf[:database]
    else
      raise "only mysql and postgresql are supported for now"
    end

    cmd = cmd.join(" ")
    puts "connecting to db: #{cmd}"
    exec(cmd)

  end
end
