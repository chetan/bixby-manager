
require 'helper'

module Bixby
module Test

class AgentExec < TestCase

  def setup
    super
    setup_test_bundle("support", "test_bundle", "echo")
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
  end

  def setup_root
    # copy repo to path
    `mkdir -p #{@root_dir}/repo/support`
    `cp -a #{@bundle_path} #{@root_dir}/repo/support/`
  end

  def test_exec_error
    # throws the first time
    assert_throws(BundleNotFound) do
      @agent.exec(@c.to_hash)
    end
  end

  def test_exec_pass
    setup_root()
    (status, stdout, stderr) = @agent.exec(@c.to_hash)
    assert status
    assert stdout
    assert stderr
    assert(status.success?)
    assert_equal("hi\n", stdout)
    assert_equal("", stderr)
  end

  def test_exec_digest_changed_throws_error
    setup_root()
    @c.digest = "lkjasdfasdf"
    assert_throws(BundleNotFound) do
      @agent.exec(@c.to_hash)
    end
  end

end

end
end
