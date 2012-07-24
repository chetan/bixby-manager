
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
        c = OpenSSL::Cipher.new("AES-256-CBC")
        c.encrypt
        key = c.random_key
        iv = c.random_iv
        encrypted = c.update(msg) + c.final

        out = []
        out << Base64.encode64(@agent.private_key.public_encrypt(key)).gsub(/\n/, "\\n")
        out << Base64.encode64(server_private_key.private_encrypt(iv)).gsub(/\n/, "\\n")
        out << Base64.encode64(encrypted)

        return out.join("\n")
      end

      def decrypt_from_agent(data)
        data = StringIO.new(data, 'rb')
        key = server_private_key.private_decrypt(Base64.decode64(data.readline.gsub(/\\n/, "\n")))
        iv = @agent.private_key.public_decrypt(Base64.decode64(data.readline.gsub(/\\n/, "\n")))

        c = OpenSSL::Cipher.new("AES-256-CBC")
        c.decrypt
        c.key = key
        c.iv = iv

        data = Base64.decode64(data.read)
        ret = c.update(data) + c.final
      end

    end

  end
end
