
# This config can be reloaded to pick up a new ruby version
#
# sudo /etc/init.d/bixby-server god load /var/www/bixby/current/config/deploy/god/rvm.god


# Wrapper script used to run the proper ruby version via rvm
# Commands in god configs should be prefixed like:
# "#{RVM_WRAPPER} bundle exec script/puma"
if not Module.const_defined? :RVM_WRAPPER then
  RVM_WRAPPER = File.join(RAILS_ROOT, "config", "deploy", "rvm_wrapper.sh")
end

# used by RVM_WRAPPER script to set up the env
conf = YAML.load_file(File.join(RAILS_ROOT, "config", "bixby.yml"))[RAILS_ENV]
ENV["USE_RUBY_VERSION"] = conf["ruby"]
ENV["USE_RVM"]          = (conf["rvm"] == "system" ? "system" : conf["user"])
