require 'test_helper'

class Bixby::Test::Modules::Repository < Bixby::Test::TestCase

  def setup
    super
    @tmp = Dir.mktmpdir("bixby-")
    @wd = Dir.pwd
    Dir.chdir(@tmp)
    ENV["BIXBY_HOME"] = @tmp
  end

  def teardown
    super
    FileUtils.rm_rf(@tmp)
    Dir.chdir(@wd)
  end

  def test_git_repo_clone

    path = File.join(@tmp, "repo.git")
    FileUtils.mkdir_p(path)
    Dir.chdir(path)
    system("git init > /dev/null")
    system("echo hi > readme")
    system("git add readme > /dev/null")
    system("git commit -m 'import' > /dev/null")

    org = FactoryGirl.create(:org)
    repo = Repo.new
    repo.org = org
    repo.name = "test"
    repo.uri = path
    repo.save!

    Bixby::Repository.new.update

    assert File.directory? repo.path
    assert File.exists? File.join(repo.path, "readme")

    system("ls -al #{@tmp}/repo/")

  end


end
