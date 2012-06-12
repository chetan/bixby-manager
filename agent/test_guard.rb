#!/usr/bin/env ruby

# test_guard.rb
# Chetan Sarva <chetan@pixelcop.net>
#
# USAGE
#
# Copy test_guard.rb to project directory
# ./test_guard.rb [dir2 ...]
#
# By default, only the directory in which test_guard.rb resides is watched.
#
# To watch other projects as well, give their path on the command line.
# This is useful for retesting when a dependent gem is modified, for instance.
#
#
# REQUIREMENTS
#
# Growl for notifications - http://growl.info/
#
# Gems:
# gem install guard growl simplecov hirb colorize

require 'rubygems'
require 'guard'
require 'growl'
require 'simplecov'
require 'hirb'
require 'colorize'

ROOT = File.expand_path(File.dirname(__FILE__))
PROJECT = File.basename(ROOT)
Dir.chdir(ROOT)

def growl(msg)
  Growl.notify msg, :title => "test_guard: #{PROJECT}", :sticky => true
end

class Watcher

  def initialize(path = nil)
    @path = path
  end

  def run_bundle
    puts "-"
    puts "running: bundle update"
    puts "-" * 80
    puts
    system("bundle update")
    if not $?.success? then
      growl("bundle update failed!")
    end
    run_test()
  end

  def run_test
    puts "-"
    puts "running: rake test"
    puts "-" * 80
    puts
    system("rake test")
    if not $?.success? then
      growl("rake test failed!")
    end
    show_coverage()
  end

  def show_coverage()
    result = SimpleCov.result
    puts
    puts "COVERAGE: #{colorize(pct(result))} -- #{result.covered_lines}/#{result.total_lines} lines"
    puts

    files = result.files.sort{ |a,b| a.covered_percent <=> b.covered_percent }

    table = files.map{ |f| { :file => f.filename.gsub(ROOT + "/", ''), :coverage => pct(f) } }

    if table.size > 15 then
      table = table.slice(0, 15)
    end

    s = Hirb::Helpers::Table.render(table).split(/\n/)
    s.pop
    puts s.join("\n").gsub(/\d+\.\d+%/) { |m| colorize(m) }

    puts
    puts "URL: file://#{ROOT}/coverage/index.html"
  end

  def pct(obj)
    sprintf("%6.2f%%", obj.covered_percent)
  end

  def colorize(s)
    s =~ /([\d.]+)/
    n = $1.to_f
    if n >= 90 then
      s.colorize(:green)
    elsif n >= 80 then
      s.colorize(:yellow)
    else
      s.colorize(:red)
    end
  end

  def on_change(files)
    b = t = false
    changes = []
    files.each do |f|

      if f == "Gemfile" then # ignore .lock
        b = true
      elsif f =~ %r{^test/} then
        if ROOT == @path then
          # run if any tests for *this* project change
          t = true
        end
      elsif f =~ /\.rb$/ then
        t = true
      end

      if b or t then
        changes << f
      end

    end

    if not changes.empty? then
      system("clear")
      puts
      changes.each { |f| puts "changed file: #{f}" }
    end

    sleep 1 # wait for changes to flush to disk??

    if b then
      run_bundle()
    elsif t then
      run_test()
    end
  end

end # class Watcher

dirs = [ ROOT ]
ARGV.each do |d|
  if File.directory? d then
    dirs << File.expand_path(d)
  end
end

system("clear")
Watcher.new.run_test()

threads = []
listeners = []

dirs.each do |dir|
  watcher = Watcher.new(dir)
  listener = Listen.to(dir) do |mod, add, del|
    files = mod + add + del
    watcher.on_change(files)
  end
  listeners << listener
  threads << Thread.new do
    listener.start
  end
end

begin
  threads.each do |t|
    t.join()
  end
rescue Exception => ex
end

puts
puts "bye!"
