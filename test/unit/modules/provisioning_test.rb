
require 'test_helper'

module Bixby
class Test::Modules::Provisioning < Bixby::Test::TestCase

  def setup
    super

    Bixby.repo_path = "#{Rails.root}/test"
    @repo  = Repo.new(:name => "support")
    @agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
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
    assert_equal File.join(Bixby.repo_path, "support", "test_bundle", "bin/echo"), dl.filename

  end

  def test_provision_missing_bundle
    Bixby.repo_path = "#{Rails.root}/test"
    repo  = Repo.new(:name => "support")
    agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    cmd   = Command.new(:bundle => "test_bundle", :command => "echofoo", :repo => repo)

    assert_throws RuntimeError do
      Bixby::Provisioning.new.provision(agent, cmd)
    end

  end

end # Test::Modules::Provisioning
end # Bixby
