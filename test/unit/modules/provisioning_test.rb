
require 'test_helper'

module Bixby

class Test::Modules::Provisioning < Bixby::Test::TestCase

  def setup
    super

    ENV["BIXBY_HOME"] = File.join(Rails.root, "test", "support", "root_dir")
    Bixby.instance_eval{ @client = nil }

    @repo  = Repo.new(:name => "vendor")
    @agent = FactoryGirl.create(:agent)
    @cmd   = Command.new(:bundle => "test_bundle", :command => "echo", :repo => @repo)
  end

  def test_list_files
    files = Bixby::Provisioning.new.list_files(@cmd.to_command_spec.to_hash)
    assert_equal 3, files.length
    assert files.first.keys.include? "file"
    assert files.first.keys.include? "digest"
  end

  def test_fetch_file
    dl = Bixby::Provisioning.new.fetch_file(@cmd, "bin/echo")
    assert dl
    assert dl.kind_of? Bixby::FileDownload
    assert_equal File.join(Bixby.repo_path, "vendor", "test_bundle", "bin/echo"), dl.filename
  end

  def test_provision_missing_bundle
    cmd = Command.new(:bundle => "test_bundle", :command => "echofoo", :repo => @repo)
    assert_throws RuntimeError do
      Bixby::Provisioning.new.provision(@agent, cmd)
    end
  end

  def test_provision_self

    res = []
    res << JsonResponse.new("fail", "bundle not found: digest does not match ('my_old_hash_XXXX' != 'yyyy')", nil, 404).to_json
    res << JsonResponse.new("success").to_json

    # 1. call to provision test_bundle/echo command FAILS because get_bundle itself is out of date
    # 3. second call to this stub succeeds
    stub1 = stub_request(:post, "http://2.2.2.2:18000/").with{ |req|
        b = req.body
        b =~ /test_bundle/ && b =~ /echo/ && b =~ /get_bundle.rb/ && b =~ %r{system/provisioning}
      }.to_return{ {:status => 200, :body => res.shift} }

    # 2. call to provision get_bundle which succeeds
    stub2 = stub_request(:post, "http://2.2.2.2:18000/").with{ |req|
        b = req.body
        b !~ /test_bundle/ && b =~ /get_bundle.rb/ && b =~ %r{system/provisioning} && b =~ /digest":"my_old_hash_XXXX/
      }.to_return(:status => 200, :body => JsonResponse.new("success").to_json)

    Bixby::Provisioning.new.provision(@agent, @cmd)

    assert_requested(stub1, :times => 2)
    assert_requested(stub2)
  end

  def test_provision_self_only

    res = []
    res << JsonResponse.new("fail", "bundle not found: digest does not match ('my_old_hash_XXXX' != 'yyyy')", nil, 404).to_json
    res << JsonResponse.new("success").to_json

    # 1. call to provision test_bundle/echo command FAILS because get_bundle itself is out of date
    stub1 = stub_request(:post, "http://2.2.2.2:18000/").with{ |req|
        b = req.body
        b =~ /get_bundle.rb/ && b =~ %r{system/provisioning} && b =~ /digest":"2429629015110c/
      }.to_return{ {:status => 200, :body => res.shift} }

    # 2. call to provision get_bundle which succeeds
    stub2 = stub_request(:post, "http://2.2.2.2:18000/").with{ |req|
        b = req.body
        b =~ /get_bundle.rb/ && b =~ %r{system/provisioning} && b =~ /digest":"my_old_hash_XXXX/
      }.to_return(:status => 200, :body => JsonResponse.new("success").to_json)

    cmd = Command.new(:bundle => "system/provisioning", :command => "get_bundle.rb", :repo => @repo)
    Bixby::Provisioning.new.provision(@agent, cmd)

    assert_requested(stub1)
    assert_requested(stub2)

    assert_requested :post, "http://2.2.2.2:18000/", :times => 2
  end

  # provisioning package A should also provision package B which it depends on
  def test_provision_dependent_packages

    stub_api.expect{ |agent, op, params|
      params[:command] == "get_bundle.rb"
      }.returns(JsonResponse.new("success")).times(2)

    @cmd.bundle = "test_bundle_with_dep"
    Bixby::Provisioning.new.provision(@agent, @cmd)

    assert_api_requests
  end

  def test_upgrade_agent
    res = CommandResponse.new({:status => 0, :stdout => "bixby upgraded to 0.2.0-alpha\n"})
    stub_api.expect{ |agent, op, params|
      params[:command] == "upgrade_agent.sh" && agent == @agent
    }.returns(res).times(2)

    assert_equal "0.2.0-alpha", Bixby::Provisioning.new.upgrade_agent(@agent.host)
    assert_equal "0.2.0-alpha", Bixby::Provisioning.new.upgrade_agent(@agent)

    assert_api_requests
  end


end # Test::Modules::Provisioning
end # Bixby
