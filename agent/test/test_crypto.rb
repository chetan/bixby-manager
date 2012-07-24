
require 'helper'

module Bixby
module Test

class Crypto < TestCase

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
    input = encrypt_for_agent("foobar")
    assert_equal "foobar", @agent.decrypt_from_server(input)
  end

  # This test is the same as Bixby::Test::Provisioning.test_list_files except
  # that crypto routines are enabled.
  def test_api_call_with_crypto

    setup_test_bundle("local", "system/provisioning", "get_bundle.rb")
    require @c.command_file
    ENV["BIXBY_NOCRYPTO"] = "0"
    setup_existing_agent()

    ret_data = encrypt_for_agent("{}")
    stub_request(:post, @api_url).to_return(:status => 200, :body => ret_data)
    Agent.stubs(:create).returns(@agent)

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    provisioner = Provision.new
    ret = provisioner.list_files(cmd)

    assert_requested(:post, @manager_uri + "/api", :times => 1) { |req|
      not req.body.include? "operation"
    }
  end

end

end
end
