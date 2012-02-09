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
  SimpleCov.start
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
end

MiniTest::Unit.autorun
