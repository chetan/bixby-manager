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

# backend
gem "memcached"
gem "mysql2"
gem "curb"

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
gem "resque", :git => "https://github.com/defunkt/resque.git"
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
    gem "coffee-script-source", :git => "https://github.com/chetan/coffee-script.git", :branch => "gem"
    # adds :coffeescript filter to haml
    # gem "coffee-filter"
    gem 'haml_assets'
    gem 'yui-compressor'
    gem 'uglifier'
end

group :development do

    # debugging
    gem "ruby-debug",   :platforms => :mri_18
    gem "debugger",     :platforms => :mri_19
    gem "awesome_print"

    # newrelic
    gem 'newrelic_rpm'
    gem 'rpm_contrib'
    # disabling due to incompat with current redis gem
    # gem 'newrelic-redis'

    # docs
    gem "yard"
    gem "redcarpet"
    gem 'apipie-rails', :git => 'git://github.com/Pajk/apipie-rails.git'
    gem "rest-client"
    gem "oauth"

    # utils
    gem "lorem_ipsum", :git => 'git://github.com/chetan/lorem_ipsum.git'
    gem "pry"
    gem "pry-rails"
    gem "hirb"
    gem "sextant"

    gem "test_guard", :git => "https://github.com/chetan/test_guard.git"
    gem 'rb-fsevent', '~> 0.9.1' if RbConfig::CONFIG['target_os'] =~ /darwin(1.+)?$/i
    gem 'rb-inotify', '~> 0.8.8', :github => 'mbj/rb-inotify' if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'wdm',        '~> 0.0.3' if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i

    # coverage
    gem "rcov",       :platforms => :mri_18
    gem "rcov_rails", :platforms => :mri_18
    gem "simplecov",  :platforms => :mri_19, :git => "https://github.com/colszowka/simplecov.git"
    gem "simplecov-html", :platforms => :mri_19, :git => "git://github.com/chetan/simplecov-html.git"

    # quality
    gem "cane", :platforms => :mri_19

    # test tools (frameworks, mock, runners, etc)
    gem 'webmock', :git => 'https://github.com/bblimke/webmock.git', :require => false
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
    gem "guard"
    gem "growl"
    gem "colorize"
end
