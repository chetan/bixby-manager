# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

require "ext/rake_disable_logging"

Bixby::Application.load_tasks

# create non-digest versions of files just in case
after 'assets:precompile' do
  Rake::Task["assets:zopfli"].invoke
  Rake::Task["assets:shorten_filenames"].invoke
end
