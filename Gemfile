source 'https://rubygems.org'

# need jruby alternative for:
# curb_threadpool
# scrypt

gem 'rails', '~>3.2'

gem 'bixby-common', :git => "https://github.com/chetan/bixby-common.git"
# gem 'bixby-common', :path => "../common"

# webserver
gem "unicorn",  :platforms => :mri

# backend
gem "memcached",                        :platforms => [:mri, :rbx]
gem "jruby-memcached",                  :platforms => :jruby

# adds foreign key support to activerecord
gem "foreigner"
gem "immigrant"

gem "mysql2",                           :platforms => [:mri, :rbx]
gem "activerecord-jdbcmysql-adapter",   :platforms => :jruby

gem "pg",                                   :platforms => [:mri, :rbx]
gem "activerecord-jdbcpostgresql-adapter",  :platforms => :jruby

gem "curb",                             :platforms => [:mri, :rbx]
gem "curb_threadpool",                  :platforms => [:mri, :rbx] # used in continuum gem
gem "httpclient",                       :platforms => :jruby

# misc/production support
gem "secure_headers"
gem "rack-health", :require => "rack/health"
gem "logging"
gem "logging-rails", :require => "logging/rails",
                     :git     => "https://github.com/chetan/logging-rails.git",
                     :branch  => "bixby"
gem "lograge"
gem "exception_notification"

# view related
gem 'haml'

# bixby requirements
gem "json",         :platforms => [:mri, :rbx, :jruby]
gem "multi_json"
gem "oj",           :platforms => [:mri, :rbx]
gem "scrypt"
gem "authlogic"
gem "api-auth"

gem "git"

# rails plugins
gem "acts-as-taggable-on"
gem "acts_as_tree"      # replace with closure_tree (better perf)?
gem "delete_paranoid"   # https://github.com/socialcast/delete_paranoid

# notifications module
gem "twilio-ruby"
gem "pony"

# metrics
gem "mongoid"

# scheduler module
# though hiredis is an extension, it should degrade gracefull for jruby
gem "hiredis"
gem "redis", "~> 3.0", :require => ["redis/connection/hiredis", "redis"]

gem "resque"
gem "resque-scheduler", :require => ["resque_scheduler"]

gem "sidekiq", "~> 2.9"
gem "slim", "~> 1.3.0"     # for sidekiq web ui
gem "sinatra"              # for sidekiq web ui

# metrics module
gem 'continuum', :git => "https://github.com/chetan/continuum.git"

group :assets do
    gem 'turbo-sprockets-rails3'
    gem 'sass'
    gem 'sass-rails'
    gem 'sprockets-jst-str'
    gem "coffee-script"
    gem "coffee-script-source"
    gem 'haml_assets'
    gem 'yui-compressor', :git => "https://github.com/loe/ruby-yui-compressor.git" # use this fork for latest 2.4.7 jar
    gem 'uglifier'
end

group :development do

    # servers used during dev
    gem "thin", :platforms => :mri
    gem "puma", :platforms => :mri

    gem "sqlite3", :platforms => :mri
    gem "activerecord-jdbcsqlite3-adapter", :platforms => "jruby"

    # debugging
    gem "ruby-debug",   :platforms => :mri_18
    gem "debugger",     :platforms => [:mri_19, :mri_20]
    gem "debugger-pry", :require => "debugger/pry", :platforms => [:mri_19, :mri_20]
    gem "awesome_print"
    gem "coffee-rails-source-maps"

    # rails debugging helpers
    gem "letter_opener"
    gem "better_errors"
    gem "binding_of_caller", :platforms => [:mri_19, :mri_20, :rbx] # used by better_errors for advanced features
    gem "xray", :require => "xray/thread_dump_signal_handler"
    gem "quiet_assets"

    # newrelic
    gem 'newrelic_rpm',     :require => false
    gem 'rpm_contrib',      :require => false
    gem 'newrelic-redis',   :require => false

    # docs
    gem "yard"
    gem "redcarpet", :platforms => [:mri, :rbx]
    gem "annotate", ">= 2.5.0"

    # utils
    gem "pry"
    gem "pry-rails"
    gem "sextant" # displays routes at http://localhost:3000/rails/routes in dev mode
    gem "highline"


    # deployment
    gem "capistrano",     :require => false
    gem "rvm-capistrano", :require => false

    # coverage
    gem "rcov",                 :platforms => :mri_18
    gem "rcov_rails",           :platforms => :mri_18
    gem "simplecov",            :platforms => [:mri_19, :mri_20], :require => false
    gem "simplecov-html",       :platforms => [:mri_19, :mri_20], :git => "https://github.com/chetan/simplecov-html.git", :require => false
    gem "simplecov-console",    :platforms => [:mri_19, :mri_20], :git => "https://github.com/chetan/simplecov-console.git", :require => false

    # quality
    gem "cane", :platforms => [:mri_19, :mri_20], :require => false

    # test tools (frameworks, mock, runners, etc)
    gem 'rake-hooks', :require => false
    gem 'webmock', :require => false
    gem "minitest"
    gem 'mocha', :require => false
    gem "turn"
    gem "bahia"
    # gem "zeus" # including the gem here appears to break zeus in ruby 2.0
    gem 'spork', :git => "https://github.com/sporkrb/spork.git", :require => false
    gem 'spork-testunit', :git => "https://github.com/sporkrb/spork-testunit.git", :require => false
    gem "spork-rails", :require => false
    gem "database_cleaner"
    gem "factory_girl_rails"
    gem "mock_redis"

    # test utils
    gem "test_guard", :git => "https://github.com/chetan/test_guard.git"
    gem 'rb-inotify', :require => false
    gem 'rb-fsevent', :require => false
    gem 'rb-fchange', :require => false

end
