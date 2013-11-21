
require 'helper'

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

    # add a bin script
    binpath = File.join(path, "foo/bar/bin")
    FileUtils.mkdir_p(binpath)
    Dir.chdir(binpath)
    system("echo echo hi > echo.sh")
    system("chmod 755 echo.sh")
    g.add("foo/bar/bin/echo.sh")
    g.commit("added echo.sh")

    # create repo
    org = FactoryGirl.create(:org)
    repo = Repo.new
    repo.org = org
    repo.name = "test"
    repo.uri = path
    repo.save!

    # this should clone the repo
    Bixby::Repository.new.update

    assert_equal "0001_test", File.basename(repo.path)
    assert File.directory? repo.path
    assert File.exists? File.join(repo.path, "readme")

    # check our new command
    script = File.join(binpath, "echo.sh")
    assert File.exists? script
    c = Command.first
    assert c
    assert_equal "echo.sh", c.command
    assert_equal "foo/bar", c.bundle

    # add a new file
    Dir.chdir(path)
    system("echo yo > readme2")
    g.add("readme2")
    g.commit("test2")
    refute File.exists? File.join(repo.path, "readme2")

    # try updating the repo now, file should exist
    Bixby::Repository.new.update
    assert File.exists? File.join(repo.path, "readme2")
    assert_equal "yo\n", File.read(File.join(repo.path, "readme2"))

    # remove our command, it should get deleted
    g.remove(script)
    g.commit("removed script")

    Bixby::Repository.new.update
    refute File.exists? script
    refute Command.first
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

    # stub the actual remote clone & pull
    Git::Base.expects(:clone).with() {
      FileUtils.mkdir_p(File.join(repo.path, ".git")) # fake it for update
      ENV.include?("GIT_SSH") && ENV.include?("GIT_SSH_BIXBY") && ENV["GIT_SSH"] =~ /gitsshwrap\.sh/
    }
    Git::Base.any_instance.expects(:pull).with() {
      ENV.include?("GIT_SSH") && ENV.include?("GIT_SSH_BIXBY") && ENV["GIT_SSH"] =~ /gitsshwrap\.sh/
    }

    Bixby::Repository.new.update
  end


end
