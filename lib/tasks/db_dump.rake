
namespace :db do

  desc "dump the database to a file (mysql only)"
  task :backup do
    conf = YAML.load(File.open(File.join(::Rails.root.to_s, "config", "database.yml")))
    conf = conf[Rails.env].with_indifferent_access

    if conf[:adapter] !~ /mysql/ then
      raise "only mysql is supported (#{Rails.env} is configured for #{conf[:adapter]})"
    end

    cmd = %w{mysqldump}
    cmd << "-h" + (conf[:host] ? conf[:host] : "localhost")
    cmd << "-u" + (conf[:username] ? conf[:username] : "root")
    cmd << "-p" if conf[:password]
    cmd << conf[:database]
    cmd << ">"
    cmd << conf[:database] + "-" + Time.new.strftime("%Y%m%d.%H%M%S") + ".sql"

    cmd = cmd.join(" ")
    puts "dumping db: #{cmd}"
    exec(cmd)
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
