
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

When /^I create an agent$/ do
    @agent = Agent.create(@manager_uri, @root_dir)
    @agent.save_config()
end

Then /^I should have "(.*?)" Agent$/ do |arg|
    bool = ("a new" == arg)
    assert(@agent.new? == bool)
end

Then /^a config file should be written$/ do
    assert( File.exists? File.join(@root_dir, "etc", "devops.yml") )
end
