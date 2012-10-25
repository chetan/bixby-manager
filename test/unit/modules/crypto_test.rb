require 'test_helper'

module Bixby
class Test::Modules::Crypto < Bixby::Test::TestCase

  def teardown
    super
    BIXBY_CONFIG[:crypto] = false
  end

  def test_has_key
    t = FactoryGirl.create(:tenant)
    assert t
    assert t.private_key
    assert t.private_key =~ /BEGIN RSA PRIVATE KEY/
  end

  def test_enabled
    a = Bixby::API.new
    refute a.crypto_enabled?
    BIXBY_CONFIG[:crypto] = true
    assert a.crypto_enabled?
  end

  def test_encrypt_for_agent
    agent = FactoryGirl.create(:agent)
    a = Bixby::API.new
    assert agent
    assert a

    ret = a.encrypt_for_agent(agent, "foobar")
    assert a !~ /foobar/
  end

  def test_decrypt_from_agent
    agent = FactoryGirl.create(:agent)
    api = Bixby::API.new

    crypt = encrypt_for_server(agent, "foobar")

    ret = api.decrypt_from_agent(agent, crypt)
    assert_equal "foobar", ret
  end

  def test_exec_api_with_crypto

    repo  = Repo.new(:name => "vendor")
    agent = FactoryGirl.create(:agent)
    cmd   = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)

    data = JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json
    crypt = encrypt_for_server(agent, data)

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      req.body !~ /operation/
    }.to_return(:status => 200, :body => crypt)

    BIXBY_CONFIG[:crypto] = true
    ret = Bixby::RemoteExec.exec(agent, cmd)

    assert_requested(stub)
    assert ret.success?
  end

  private

  def encrypt_for_server(agent, payload)
    server_pem = OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
    agent_pem = OpenSSL::PKey::RSA.new(agent.private_key)
    Bixby::CryptoUtil.encrypt(payload, agent.uuid, server_pem, agent_pem)
  end

end # Test::Modules::Crypto
end # Bixby
