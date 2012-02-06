
begin
  require 'rubygems'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "devops_common"
    gemspec.summary = "Devops Common"
    gemspec.description = "Devops Common files/libs"
    gemspec.email = "chetan@pixelcop.net"
    gemspec.homepage = "http://github.com/chetan/devops"
    gemspec.authors = ["Chetan Sarva"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Dir['tasks/**/*.rake'].each { |rake| load rake }


require "yard"
YARD::Rake::YardocTask.new("docs") do |t|
end
