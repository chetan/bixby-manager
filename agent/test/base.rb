
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

        BaseModule.manager_uri = @manager_uri
        @api_url = @manager_uri + "/api"

        `rm -rf #{@root_dir}`

        ENV["BIXBY_NOCRYPTO"] = "1"
        ENV["BIXBY_HOME"] = @root_dir
        ARGV.clear
      end

      def teardown
        `rm -rf #{@root_dir}`
        @agent = nil
      end

      def setup_existing_agent
        ENV["BIXBY_HOME"] = @root_dir
        src = File.expand_path(File.join(File.dirname(__FILE__), "support/root_dir"))
        dest = File.join(@root_dir, "etc")
        FileUtils.mkdir_p(dest)
        FileUtils.copy_entry(src, dest)
        @agent = Agent.create
      end

      def setup_test_bundle(repo, bundle, command)
        @bundle_path = File.expand_path(File.dirname(__FILE__)) + "/support/test_bundle"
        @c = CommandSpec.new({ :repo => repo, :bundle => bundle, :command => command })
      end

      def create_new_agent
        ENV["BIXBY_HOME"] = nil
        @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
      end


      # common routines for crypto tests

      def server_private_key
        s = File.join(@root_dir, "etc", "server")
        OpenSSL::PKey::RSA.new(File.read(s))
      end

      def encrypt_for_agent(msg)
        Bixby::CryptoUtil.encrypt(msg, "server_uuid", @agent.private_key, server_private_key)
      end

      def decrypt_from_agent(data)
        data = StringIO.new(data, 'rb')
        uuid = data.readline.strip
        Bixby::CryptoUtil.decrypt(data, server_private_key, @agent.private_key)
      end

    end

  end
end
