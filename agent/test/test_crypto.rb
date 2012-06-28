
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

    input = Base64.encode64(@agent.private_key.public_encrypt("foobar"))
    assert_equal "foobar", @agent.decrypt_from_server(input)
  end

end

end
end
