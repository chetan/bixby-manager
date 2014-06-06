
# Main God config
#
# usage:
#
#   # RAILS_ENV="staging" god -c /var/www/bixby/current/config/deploy/bixby.god
#
# god must be run as root!
#
# see also: http://godrb.com/

RAILS_ENV    = (ENV['RAILS_ENV']  ||= 'production')
RAILS_ROOT   = (ENV['RAILS_ROOT'] ||= '/var/www/bixby/current')

conf  = YAML.load_file(File.join(RAILS_ROOT, "config", "bixby.yml"))[RAILS_ENV]
USER  = conf["user"]
GROUP = conf["group"]

%w{rvm puma sidekiq}.each do |file|
  God.load File.join(RAILS_ROOT, "config", "deploy", "god", "#{file}.god")
end
