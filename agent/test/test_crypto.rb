
require 'helper'

module Bixby
module Test

class Crypto < TestCase

  def setup
    super
    @manager_uri = "http://localhost:3000"
    @password = "foobar"
    @root_dir = "/tmp/agent_test_temp"
    @port = 9999
    `rm -rf #{@root_dir}`
    ENV["BIXBY_HOME"] = @root_dir
    ARGV.clear
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

  def test_keygen
    create_new_agent()

    assert File.exists? @agent.private_key_file
    assert @agent.private_key
    assert @agent.public_key
  end

  def test_server_key
    setup_existing_agent()

    assert @agent.have_server_key?
    assert @agent.server_key
    assert @agent.encrypt_for_server("foobar")
  end

  def test_decrypt
    setup_existing_agent()

    input = Base64.encode64(@agent.private_key.public_encrypt("foobar"))
    assert_equal "foobar", @agent.decrypt_from_server(input)
  end

end

end
end
