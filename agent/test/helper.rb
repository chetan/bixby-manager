require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/unit'
require 'turn'

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

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'devops_agent'

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

MiniTest::Unit.autorun
