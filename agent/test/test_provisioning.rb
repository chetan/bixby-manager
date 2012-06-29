
require 'helper'

module Bixby
module Test

class Provisioning < TestCase

  def setup
    super
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
  end

  def test_list_files

    stub_request(:post, @api_url).to_return(:status => 200, :body => '{}')
    Agent.stubs(:create).returns(@agent)

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    provisioner = Provision.new
    ret = provisioner.list_files(cmd)

    assert_requested(:post, @manager_uri + "/api", :times => 1) { |req|
      req.body == '{"operation":"provisioning:list_files","params":{"repo":"support","bundle":"test_bundle","command":"echo"}}'
    }

  end

  def test_download_files

    Agent.stubs(:create).returns(@agent)

    path = File.expand_path(File.dirname(__FILE__)) + "/support/test_bundle/bin"
    sha = Digest::SHA2.new

    `mkdir -p #{@root_dir}/repo/support/test_bundle/`
    `cp -a #{path}/../ #{@root_dir}/repo/support/test_bundle/`

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    files = [
      { "file" => "bin/echo", "digest" => "foo" }, # force "changed" digest
      { "file" => "bin/cat", "digest" => "foo" },
      { "file" => "manifest.json", "digest" => sha.hexdigest(File.read("#{path}/../manifest.json")) }
    ]

    body1 = '{"operation":"provisioning:fetch_file","params":[{"repo":"support","bundle":"test_bundle","command":"echo"},"bin/echo"]}'
    body2 = '{"operation":"provisioning:fetch_file","params":[{"repo":"support","bundle":"test_bundle","command":"echo"},"bin/cat"]}'

    req1 = stub_request(:post, @api_url).with(:body => body1, :times => 1).to_return(:status => 200, :body => File.new("#{path}/echo"))
    req2 = stub_request(:post, @api_url).with(:body => body2, :times => 1).to_return(:status => 200, :body => File.new("#{path}/cat"))

    digest_file = File.join(@root_dir, "repo", "support", "test_bundle", "digest")
    digest_mtime = File::Stat.new(digest_file).mtime.to_i

    provisioner = Provision.new
    provisioner.download_files(cmd, files)

    assert_requested(req1)
    assert_requested(req2)
    # should not receive a request for manifest.json

    file1 = File.join(@root_dir, "repo", "support", "test_bundle", "bin", "echo")
    file2 = File.join(@root_dir, "repo", "support", "test_bundle", "bin", "cat")

    # verify that files got created and with correct permissions
    [ file1, file2 ].each do |file|
      assert File.exists? file
      assert_equal 33261, File.stat(file).mode
    end

    assert_equal sha.hexdigest(File.read("#{path}/echo")), sha.hexdigest(File.read(file1))
    assert_equal sha.hexdigest(File.read("#{path}/cat")), sha.hexdigest(File.read(file2))

    refute_equal digest_mtime, File::Stat.new(digest_file).mtime.to_i

  end

end

end
end
