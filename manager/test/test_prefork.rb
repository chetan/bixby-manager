

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

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
    end

    # override so we can dump stdout/stderr even if the test passes
    def pass(message=nil)
      io.puts " %s %s" % [ticktock, PASS]

      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(TAB_SIZE)
        io.puts(message)
      end

      show_captured_output
    end

    # override to add test name to output
    def show_captured_stdout
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

if $0 == __FILE__ then
  # require all test cases if not running via rake
  $: << File.expand_path(File.dirname(__FILE__))
  Dir.glob(File.expand_path(File.dirname(__FILE__)) + "/**/*.rb").each do |f|
    next if f =~ /test\/performance/ or f == File.expand_path(__FILE__)
    require f
  end
end


# load curb first so webmock can stub it out as necessary
require 'curb'
require 'curb_threadpool'
require 'webmock'
require 'mocha'


class ActiveSupport::TestCase

  include WebMock::API

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class MiniTest::Unit::TestCase

  # minitest assert_throws doesn't seem to work properly
  def assert_throws(clazz, msg = nil, &block)
    begin
      yield
    rescue Exception => ex
      if clazz.to_s == ex.class.name then
        if msg.nil?
          return
        elsif msg == ex.message then
          return
        end
      end
      puts "unexpected exception caught:"
      puts "#{ex.class}: #{ex.message}"
      puts ex.backtrace.join("\n")
      puts
    end
    flunk("Expected #{mu_pp(clazz)} to have been thrown")
  end

end

# setup database_cleaner
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

MiniTest::Unit.autorun
