
require 'aruba/cucumber'

require 'minitest/unit'
World(MiniTest::Assertions)

# load curb first so webmock can stub it out as necessary
require 'curb'
require 'webmock/cucumber'
include WebMock::API

require 'fileutils'

$: << File.expand_path(File.join(File.dirname(__FILE__), "../../lib"))
require 'devops_agent'
