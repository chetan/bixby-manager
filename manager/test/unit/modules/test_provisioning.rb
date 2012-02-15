
class TestProvisioning < ActiveSupport::TestCase

  def setup
    WebMock.reset!

    BundleRepository.path = "#{Rails.root}/test"
    @repo  = Repo.new(:name => "support")
    @agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    @cmd   = Command.new(:bundle => "test_bundle", :command => "echo", :repo => @repo)
  end

  def test_list_files

    files = Provisioning.new.list_files(@cmd.to_command_spec.to_hash)
    assert_equal 2, files.length
    assert files.first.keys.include? :file
    assert files.first.keys.include? :digest

  end

  def test_fetch_file

    dl = Provisioning.new.fetch_file(@cmd, "bin/echo")
    assert dl
    assert dl.kind_of? FileDownload
    assert_equal File.join(BundleRepository.path, "support", "test_bundle", "bin/echo"), dl.filename

  end

end
