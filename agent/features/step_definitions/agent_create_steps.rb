
Given /^there is "(.*?)" existing agent$/ do |arg|
    existing = (arg != "no")
    if existing then
        src = File.expand_path(File.join(File.dirname(__FILE__), "../support/root_dir"))
        FileUtils.mkdir_p(File.dirname(@root_dir))
        FileUtils.copy_entry(src, @root_dir)
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
end

Then /^I should have a new Agent$/ do
    assert(@agent.new? == true)
end
