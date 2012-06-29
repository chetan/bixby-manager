
require 'helper'

module Bixby
module Test

class TestAgent < TestCase

	def setup
    super
    ENV["BIXBY_HOME"] = nil
  end

  def test_create_new_agent
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
    @agent.save_config()
    assert(@agent.new?)
    assert( File.exists? File.join(@root_dir, "etc", "devops.yml") )
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir
  end

  def test_load_existing_agent
    setup_existing_agent()
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir
  end

  def test_load_existing_agent_using_env
    setup_existing_agent()
    ENV["BIXBY_HOME"] = @root_dir

    @agent = Agent.create()
    assert @agent
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir
    assert_equal @root_dir, @agent.agent_root
  end

  def test_create_missing_manager_uri
    @manager_uri = nil
    assert_throws(ConfigException) do
      @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
    end
  end

  def test_register_with_manager
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)

    # stub out http request
    stub_request(:post, "#{@manager_uri}/api").
      to_return(:body => '{"data":null,"code":null,"status":"success","message":null}', :status => 200)
    response = @agent.register_agent
    assert response.status == "success"
  end

  def test_bad_config
    setup_existing_agent()
    File.open(File.join(@root_dir, "etc", "devops.yml"), 'w') { |f| f.write("foo") }
    assert_throws(SystemExit) do
      Agent.create
    end
  end

end

end
end
