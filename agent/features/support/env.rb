
require 'aruba/cucumber'

require 'minitest/unit'
World(MiniTest::Assertions)

require 'fileutils'
require File.expand_path(File.join(File.dirname(__FILE__), "../../lib/agent/agent"))
