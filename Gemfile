source 'http://rubygems.org'

gem 'rails', '~>3.2'

gem 'bixby-common', :git => "https://github.com/chetan/bixby-common.git"

group :threads do
  gem "rainbows", :platforms => :mri
  gem "rev",      :platforms => :mri
  gem "cool.io"
end

# webserver
gem "thin", :platforms => :mri
gem "lograge"

# backend
gem "memcached"
gem "mysql2"
gem "curb"

# misc
gem "exception_notification"

# view related
gem 'haml'
gem 'simple_form'

# bixby requirements
gem "json"
gem "multi_json"
gem "oj"
gem "scrypt"

gem "SystemTimer",  :platforms => :mri_18
gem "git"

# rails plugins
gem "acts-as-taggable-on"
gem "acts_as_tree"
gem "delete_paranoid" # https://github.com/socialcast/delete_paranoid

# notifications module
gem "twilio-ruby"
gem "pony"

# scheduler module
gem "hiredis"
gem "redis", "~> 3.0", :require => ["redis/connection/hiredis", "redis"]
gem "resque" #, :git => "https://github.com/defunkt/resque.git"
gem "resque-scheduler",
  :git => "git@github.com:bvandenbos/resque-scheduler.git",
  :require => ["resque_scheduler"]
gem "redis-lock"

# metrics module
gem 'continuum', :git => "https://github.com/chetan/continuum.git"

group :assets do
    gem 'sass'
    gem 'sass-rails'
    gem 'jst_str', :git => "git://github.com/chetan/jst_str.git"
    gem "coffee-script"
    gem "coffee-script-source"
    gem 'haml_assets'
    gem 'yui-compressor'
    gem 'uglifier'
end

group :development do

    # debugging
    gem "ruby-debug",   :platforms => :mri_18
    gem "debugger",     :platforms => :mri_19
    gem "awesome_print"
    gem "letter_opener"
    gem "better_errors"
    gem "binding_of_caller"

    # newrelic
    gem 'newrelic_rpm', :require => false
    gem 'rpm_contrib', :require => false
    gem 'newrelic-redis', :require => false

    # docs
    gem "yard"
    gem "redcarpet"
    gem "annotate", ">= 2.5.0"

    # utils
    gem "pry"
    gem "pry-rails"
    gem "sextant" # displays routes at http://localhost:3000/rails/routes in dev mode

    # deployment
    gem "capistrano",     :require => false
    gem "rvm-capistrano", :require => false

    # coverage
    gem "rcov",       :platforms => :mri_18
    gem "rcov_rails", :platforms => :mri_18
    gem "simplecov",  :platforms => :mri_19, :git => "https://github.com/colszowka/simplecov.git", :require => false
    gem "simplecov-html", :platforms => :mri_19, :git => "git://github.com/chetan/simplecov-html.git", :require => false
    gem "simplecov-console", :platforms => :mri_19, :git => "git@github.com:chetan/simplecov-console.git", :require => false

    # quality
    gem "cane", :platforms => :mri_19, :require => false

    # test tools (frameworks, mock, runners, etc)
    gem 'rake-hooks', :require => false
    gem 'webmock', :require => false
    gem "minitest"
    gem 'mocha', :require => false
    gem "turn"
    gem "bahia"
    gem 'spork', :git => "https://github.com/sporkrb/spork.git", :require => false
    gem 'spork-testunit', :git => "https://github.com/sporkrb/spork-testunit.git", :require => false
    gem "spork-rails", :require => false
    gem "database_cleaner"
    gem "factory_girl_rails"

    # test utils
    gem "test_guard", :git => "https://github.com/chetan/test_guard.git"
    gem 'rb-inotify', :require => false
    gem 'rb-fsevent', :require => false
    gem 'rb-fchange', :require => false

end
