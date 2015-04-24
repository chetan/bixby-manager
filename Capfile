require 'capistrano/setup'
require 'capistrano/deploy'

require 'rvm1/capistrano3'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
