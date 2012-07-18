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
#
# For spork:
# gem install spork spork-testunit

require 'rubygems'
require 'guard'
require 'growl'
require 'simplecov'
require 'hirb'
require 'colorize'

ROOT = File.expand_path(File.dirname(__FILE__))
PROJECT = File.basename(ROOT)
Dir.chdir(ROOT)

# TEST_COMMAND = "rake test"
# TEST_COMMAND = "ruby #{ROOT}/test/test_helper.rb"
TEST_COMMAND = "testdrb test/unit/"

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

  def run_test(changes=[])
    puts "-"
    puts "running: rake test"
    puts "-" * 80
    puts

    if TEST_COMMAND =~ /testdrb/ and not changes.empty? then
      tests = changes.find_all{ |c| c =~ %r{^#{ROOT}/test/} }
      if tests.size == changes.size then
        # only tests were changed, run those specific files
        system("testdrb " + tests.join(" "))

      else
        system(TEST_COMMAND)
      end

    else
      system(TEST_COMMAND)
    end

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
      puts "showing bottom (worst) 15 of #{table.size} files"
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

      if f =~ %r{test\/(factories|test_.*?)\.rb$} or f =~ /^test_guard\.rb$/ or f =~ %r{#{ROOT}/coverage} then
        # TODO move excludes to var
        # skip changes in these files
        next
      end

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
      run_test(changes)
    end
  end

end # class Watcher

system("clear")

# delete existing coverage data
cov_dir = File.join(ROOT, "coverage")
if File.directory? cov_dir then
  puts "deleting existing coverage data\n---"
  system("rm -rf #{cov_dir}")
end

# setup directories to watch
dirs = [ ROOT ]
ARGV.each do |d|
  if File.directory? d then
    dirs << File.expand_path(d)
  end
end

# run all tests at start
Watcher.new.run_test()

# start listener for each dir
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

# wait for exit (never)
begin
  threads.each do |t|
    t.join()
  end
rescue Exception => ex
end

puts
puts "bye!"
