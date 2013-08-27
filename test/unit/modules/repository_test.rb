
require 'test_helper'

class Bixby::Test::Modules::Repository < Bixby::Test::TestCase

  def setup
    super
    @tmp = Dir.mktmpdir("bixby-")
    @wd = Dir.pwd
    Dir.chdir(@tmp)
    ENV["BIXBY_HOME"] = @tmp
    FileUtils.mkdir_p(Bixby.repo_path)
  end

  def teardown
    super
    FileUtils.rm_rf(@tmp)
    Dir.chdir(@wd)
  end

  def test_git_repo_clone_and_update

    # for some reason system() git commands directly screws up with working dir
    # issues. using git lib works..

    path = File.join(@tmp, "repo.git")
    FileUtils.mkdir_p(path)
    Dir.chdir(path)
    g = Git.init(path)
    system("echo hi > readme")
    g.add("readme")
    g.commit("import")

    org = FactoryGirl.create(:org)
    repo = Repo.new
    repo.org = org
    repo.name = "test"
    repo.uri = path
    repo.save!

    # this should clone the repo
    Bixby::Repository.new.update

    assert File.directory? repo.path
    assert File.exists? File.join(repo.path, "readme")

    # try updating the repo now
    system("echo yo > readme2")
    g.add("readme2")
    g.commit("test2")

    refute File.exists? File.join(repo.path, "readme2")

    Bixby::Repository.new.update
    assert File.exists? File.join(repo.path, "readme2")
    assert_equal "yo\n", File.read(File.join(repo.path, "readme2"))
  end

  def test_git_clone_private
    key_path = File.join(Rails.root, "test", "support", "keys")

    org = FactoryGirl.create(:org)
    repo = Repo.new
    repo.org = org
    repo.name = "test"
    repo.uri = "git@github.com:chetan/bixby-test-private-repo.git"
    repo.private_key = File.read(File.join(key_path, "id_rsa"))
    repo.public_key = File.read(File.join(key_path, "id_rsa.pub"))
    repo.save!

    # stub the actual remote pull
    Git::Base.any_instance.expects(:pull).with() {
      ENV.include?("GIT_SSH") && ENV.include?("GIT_SSH_BIXBY") && ENV["GIT_SSH"] =~ /gitsshwrap\.sh/
    }

    Bixby::Repository.new.update
  end


end
