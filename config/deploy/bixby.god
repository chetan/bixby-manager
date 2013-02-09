
RUBY_VERSION = "ruby-1.9.3-p385"
BIN_PATH     = "/home/chetan/.rvm/gems/#{RUBY_VERSION}@global/bin"

RAILS_ENV    = ENV['RAILS_ENV']  = 'production'
RAILS_ROOT   = ENV['RAILS_ROOT'] = '/var/www/bixby/current'

%w{unicorn sidekiq}.each do |file|
  God.load File.join(RAILS_ROOT, "config", "deploy", "god", "#{file}.god")
end
