
require 'helper'

class TestDevopsAgent < MiniTest::Unit::TestCase

	def setup
    @manager_uri = "http://localhost:3000"
    @password = "foobar"
    @root_dir = "/tmp/agent_test_temp"
    @port = 9999
    `rm -rf #{@root_dir}`
  end

  def setup_existing_agent
    src = File.expand_path(File.join(File.dirname(__FILE__), "support/root_dir"))
    dest = File.join(@root_dir, "etc")
    FileUtils.mkdir_p(dest)
    FileUtils.copy_entry(src, dest)
  end

  # minitest assert_throws doesn't seem to work properly
  def assert_throws(clazz, msg = nil, &block)
    begin
      yield
    rescue Exception => ex
      if clazz.to_s == ex.class.name then
        if msg.nil?
          return
        elsif msg == ex.message then
          return
        end
      end
    end
    flunk("Expected #{mu_pp(clazz)} to have been thrown")
  end

  def test_create_new_agent
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
    @agent.save_config()
    assert(@agent.new?)
    assert( File.exists? File.join(@root_dir, "etc", "devops.yml") )
  end

  def test_load_existing_agent
    setup_existing_agent()
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
    @agent.save_config()
    assert(!@agent.new?)
  end

  def test_create_missing_manager_uri
    @manager_uri = nil
    assert_throws(:ConfigException) do
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
  
  # @stdout
  # Scenario: Corrupted configuration throws error
  #   Given a manager at "http://localhost:3000"
  #   And a root dir of "/tmp/devops/test"
  #   And there is "a" existing agent
  #   And a corrupted configuration
  #   When I create an agent
  #   Then stdout should contain "exiting"
  def test_bad_config
    # TODO
  end

end
