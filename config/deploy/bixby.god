
ENV["USE_RUBY_VERSION"] = "ruby-1.9.3-p385"

RAILS_ENV    = ENV['RAILS_ENV']  = 'production'
RAILS_ROOT   = ENV['RAILS_ROOT'] = '/var/www/bixby/current'

RVM_WRAPPER  = File.join(RAILS_ROOT, "config", "deploy", "rvm_wrapper.sh")

%w{unicorn sidekiq}.each do |file|
  God.load File.join(RAILS_ROOT, "config", "deploy", "god", "#{file}.god")
end
