require 'test_helper'

module Bixby
class Test::Modules::Crypto < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:crypto'
    WebMock.reset!
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
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

    pair = OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
    crypt = Base64.encode64(pair.public_encrypt("foobar"))

    ret = api.decrypt_from_agent(agent, crypt)
    assert_equal "foobar", ret
  end

  def test_exec_api_with_crypto

    repo  = Repo.new(:name => "vendor")
    agent = FactoryGirl.create(:agent)
    cmd   = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)


    pair = OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
    crypt = Base64.encode64(pair.public_encrypt( JsonResponse.new("success", "", {:status => 0, :stdout => "frobnicator echoed"}).to_json ))

    stub = stub_request(:post, "http://2.2.2.2:18000/").with { |req|
      req.body !~ /operation/
    }.to_return(:status => 200, :body => crypt)

    BIXBY_CONFIG[:crypto] = true
    ret = Bixby::RemoteExec.exec(agent, cmd)

    assert_requested(stub)
    assert ret.success?
  end

end # Test::Modules::Crypto
end # Bixby
