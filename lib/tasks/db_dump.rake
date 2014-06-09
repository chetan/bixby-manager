
namespace :db do

  desc "dump the database to a file (mysql2 and postgresql only)"
  task :backup do
    conf = YAML.load(File.open(File.join(::Rails.root.to_s, "config", "database.yml")))
    conf = conf[Rails.env].with_indifferent_access

    if conf[:adapter] == "mysql2" then
      mysql_dump(conf)
    elsif conf[:adapter] == "postgresql" then
      pg_dump(conf)
    else
      raise "only mysql2 and postgresql are supported (#{Rails.env} is configured for #{conf[:adapter]})"
    end

  end

  desc "restore a mysql backup, ex: db:restore[foo.sql]"
  task :restore, :file do |t, args|

    file = args[:file]
    if file.blank? then
      puts "ERROR: a file is required"
      exit 1
    elsif !File.exists? file or !File.readable? file then
      puts "ERROR: #{file} doesn't exist or can't be read"
      exit 1
    end

    conf = YAML.load(File.open(File.join(::Rails.root.to_s, "config", "database.yml")))
    conf = conf[Rails.env].with_indifferent_access

    if conf[:adapter] !~ /mysql/ then
      raise "only mysql is supported (#{Rails.env} is configured for #{conf[:adapter]})"
    end

    cmd = %w{mysql}
    cmd << "-h" + (conf[:host] ? conf[:host] : "localhost")
    cmd << "-u" + (conf[:username] ? conf[:username] : "root")
    cmd << "-p" if conf[:password]
    cmd << conf[:database]
    cmd << "<"
    cmd << file

    cmd = cmd.join(" ")
    puts "restoring db: #{cmd}"
    exec(cmd)
  end

end

def mysql_dump(conf)
  cmd = %w{mysqldump}
  cmd << "-h" + (conf[:host] ? conf[:host] : "localhost")
  cmd << "-u" + (conf[:username] ? conf[:username] : "root")
  cmd << "-p" if conf[:password]

  dump(conf, cmd)
end

def pg_dump(conf)
  # pg_dump -c bixby > bixby.sql
  cmd = %w{pg_dump -Fc -bc}
  cmd << "-h" + (conf[:host] ? conf[:host] : "localhost")
  cmd << "-U" + (conf[:username] ? conf[:username] : "root")
  cmd << "-W"

  dump(conf, cmd, ".pgsql")
end

def dump(conf, cmd, ext=".sql")
  cmd << conf[:database]
  cmd << ">"
  cmd << File.join(Dir.pwd, conf[:database] + "-#{Rails.env}-" + Time.new.strftime("%Y%m%d.%H%M%S") + ext)

  cmd = cmd.join(" ")
  puts "dumping db: #{cmd}"
  system(cmd)
end
