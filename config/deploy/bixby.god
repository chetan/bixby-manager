
# TODO move vars to config file

RAILS_ENV    = ENV['RAILS_ENV']  = 'production'
RAILS_ROOT   = ENV['RAILS_ROOT'] = '/var/www/bixby/current'

RVM_WRAPPER  = File.join(RAILS_ROOT, "config", "deploy", "rvm_wrapper.sh")

# gets passed to RVM_WRAPPER SCRIPT
conf = YAML.load_file(File.join(RAILS_ROOT, "config", "bixby.yml"))[RAILS_ENV]
ENV["USE_RUBY_VERSION"] = conf["ruby"]
ENV["USE_RVM"]          = conf["rvm"]

USER  = conf["user"]
GROUP = conf["group"]

%w{unicorn sidekiq}.each do |file|
  God.load File.join(RAILS_ROOT, "config", "deploy", "god", "#{file}.god")
end
