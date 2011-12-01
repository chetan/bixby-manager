
##################################
#   GIVEN
##################################

Given /^there is "(.*?)" existing agent$/ do |arg|
    existing = (arg != "no")
    if existing then
        src = File.expand_path(File.join(File.dirname(__FILE__), "../support/root_dir"))
        dest = File.join(@root_dir, "etc")
        FileUtils.mkdir_p(dest)
        FileUtils.copy_entry(src, dest)
    end
end

Given /^a manager at "(.*)"$/ do |uri|
    @manager_uri = uri
end

Given /^a root dir of "(.*)"$/ do |path|
    @root_dir = path
end

Given /^a corrupted configuration$/ do
    if File.exists? @root_dir then
        File.open(File.join(@root_dir, "etc", "devops.yml"), 'w')
    end
end

Given /^a port of "(.*?)"$/ do |str|
    @port = str
end


##################################
#   WHEN
##################################

When /^I create an agent$/ do
    @agent = Agent.create(@manager_uri, @root_dir, @port)
    @agent.save_config()
end

When /^I register the agent$/ do
    stub_request(:post, "http://localhost:3000/api").
      to_return(:body => '{"data":null,"code":null,"status":"success","message":null}', :status => 200)
    @response = @agent.register_agent
end



##################################
#   THEN
##################################


Then /^I should have "(.*?)" Agent$/ do |arg|
    bool = ("a new" == arg)
    assert(@agent.new? == bool)
end

Then /^a config file should be written$/ do
    assert( File.exists? File.join(@root_dir, "etc", "devops.yml") )
end

Then /^it should raise (.+?) when (.+)$/ do |exception,when_step|
  lambda {
    step when_step
  }.should raise_error(eval(exception))
end

Then /^stdout should contain "(.*?)"$/ do |str|
    assert_includes( @stdout.string, str )
end

Then /^it should return "(.*?)"$/ do |str|
    assert @response.status == str
end
