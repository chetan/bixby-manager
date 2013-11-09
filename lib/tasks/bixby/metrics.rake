
namespace :bixby do

  desc "muck around with metrics"
  task :metrics => :environment do |t|

    require 'highline'
    require 'terminal-table'
    MetricsCli.new.run

  end
end

class MetricsCli
  def initialize
    @h = HighLine.new
    user(["chetan"])
  end

  def run
    while true do

      cmd = nil
      begin
        cmd = @h.ask("bixby> ")
      rescue EOFError => ex
        quit
      end
      next if cmd.blank?

      c = cmd.split(/ /)
      cmd = c.first.strip
      args = c[1, c.length]

      # lookup cmd by method name
      if self.respond_to?(cmd.to_sym) then
        self.send(cmd.to_sym, args)
        next
      end

      # handle some aliases
      case cmd
        when "q"
        when "exit"
          quit
      end

    end
  end

  def help(args=nil)
    puts <<-EOF
available commands:

  users                   list users
  user <username>         switch to the given user
  list                    list all checks
  check <id>              list metrics for the given check
  metrics <id>            show recent data for the given metric

  quit                    quit
  help                    show help

EOF
  end

  def users(args)
    table = Terminal::Table.new do |t|
      t.headings = %w{ Username Name E-Mail Org }
      User.all.each do |u|
        t << [ u.username, u.name, u.email, u.org.name ]
      end
    end

    puts table
    puts
  end

  def user(args)
    u = User.where(:username => args.first).first
    if not u.nil? then
      @user = u
      puts "ok"
    end
  end

  # list all checks
  def list(args=nil)

    table = Terminal::Table.new do |t|
      t.headings = [ "ID", "Host", "Agent", "Command" ]

      Check.where(:host_id => Host.where(:org_id => @user.org_id)).order(:id).each do |check|

        t << [ check.id, check.host.to_s, check.agent.ip, check.command.name ]

      end
    end

    puts table
    puts
  end

  # list the metrics for the given check
  def check(args)

    if not args.blank? then
      checks = [ Check.find(args.shift.to_i) ]
      puts "showing metrics for check #{checks.first.inspect}"
    else
      checks = Check.all.order(:id)
      puts "showing all metrics"
    end

    table = Terminal::Table.new do |t|
      t.headings = %w{ ID Metric Tags }

      checks.each do |check|
        metrics = check.metrics.order(:id)
        metrics.each do |m|
          tags = tag_str(m)
          t << [ m.id, m.key, tags ]
        end
      end

    end

    puts table
  end

  def tag_str(m)
    m.tags.reject{|t| t.key =~ /(host|check|org|tenant)_id$/}.map{|t| "#{t.key}=#{t.value}"}.join(", ")
  end

  # show recent data for the given metric
  def metrics(args)

    metric = Metric.find(args.shift.to_i)
    metric.load_data!

    puts <<-EOF
showing metrics for metric

id:         #{metric.id}
check_id:   #{metric.check_id}
key:        #{metric.key}
tags:       #{tag_str(metric)}

time now:   #{Time.new}
EOF

    puts ""
    puts ""

    i = 0
    table = Terminal::Table.new do |t|
      t.headings = [ "Timestamp", "Value" ]
      if metric.data.blank? then
        puts "no data!"
        break
      end

      metric.data.reverse[0..9].each do |d|
        i += 1
        t << [ Time.at(d[:time]), sprintf("%20.4f", d[:val]) ]
      end
    end

    puts table
    puts "showing top #{i} rows" if i > 0
    puts
  end

  def quit(args=nil)
    puts
    puts "\nbye!"
    exit
  end

end
