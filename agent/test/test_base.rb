
require 'helper'

module Bixby
  module Test

    class TestCase < MiniTest::Unit::TestCase

      def setup
        super
        WebMock.reset!

        @manager_uri = "http://localhost:3000"
        @password = "foobar"
        @root_dir = "/tmp/agent_test_temp"
        @port = 9999

        `rm -rf #{@root_dir}`

        ENV["BIXBY_HOME"] = @root_dir
        ARGV.clear
      end

      def teardown
        `rm -rf #{@root_dir}`
      end

      def setup_existing_agent
        src = File.expand_path(File.join(File.dirname(__FILE__), "support/root_dir"))
        dest = File.join(@root_dir, "etc")
        FileUtils.mkdir_p(dest)
        FileUtils.copy_entry(src, dest)
        @agent = Agent.create
      end

      def create_new_agent
        @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
      end

    end

  end
end
