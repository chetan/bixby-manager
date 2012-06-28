require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

module Rake
  class << self
    def verbose?
      ENV.include? "VERBOSE" and ["1", "true", "yes"].include? ENV["VERBOSE"]
    end
  end
end

require 'awesome_print'
require 'minitest/unit'
require 'turn'
require 'turn/reporter'
require 'turn/reporters/outline_reporter'

Turn.config.framework = :minitest
Turn.config.format = :outline
Turn.config.natural = true

module Turn
  class OutlineReporter < Reporter
    def start_test(test)

      @last_test = test

      # create new captures for each test (so we don't get repeated messages)
      @stdout = StringIO.new
      @stderr = StringIO.new

      name = naturalized_name(test)

      io.print "    %-57s" % name

      @stdout.rewind
      @stderr.rewind

      $stdout = @stdout
      $stderr = @stderr unless $DEBUG

      @clean = false
      at_exit do
        if not @clean then
          puts "program quit unexpectedly!"
          show_captured_output()
        end
      end
    end

    def finish_test(test)
      super
      @clean = true
    end

    # override so we can dump stdout/stderr even if the test passes
    def pass(message=nil)
      io.puts " %s %s" % [ticktock, PASS]

      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(TAB_SIZE)
        io.puts(message)
      end

      @clean = true
      show_captured_output if Rake.verbose?
    end

    # override to add test name to output
    def show_captured_stdout
      @clean = true
      @stdout.rewind
      return if @stdout.eof?
      STDOUT.puts(<<-output.tabto(8))
\n\nSTDOUT (#{naturalized_name(@last_test)}):
-------------------------------------------------------------------------------

#{@stdout.read}
      output
    end
  end
end


begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
rescue Exception => ex
end

# load curb first so webmock can stub it out as necessary
require 'curb'
require 'webmock'
include WebMock::API
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bixby_agent'

class MiniTest::Unit::TestCase

  # minitest assert_throws doesn't seem to work properly
  def assert_throws(clazz, msg = nil, &block)
    begin
      yield
    rescue Exception => ex
      puts "#{ex.class}: #{ex.message}"
      puts ex.backtrace.join("\n")
      if clazz.to_s == ex.class.name then
        if msg.nil?
          return
        elsif msg == ex.message then
          return
        end
      end
    end
    flunk("Expected #{mu_pp(clazz)} to have been thrown")
  end

end

require "base"

Dir.glob(File.dirname(__FILE__) + "/../lib/**/*.rb").each{ |f| require f }

MiniTest::Unit.autorun
