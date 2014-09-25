
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

from_email = if conf["mailer_from"] =~ /<(.*?)>/ then
  $1
else
  conf["mailer_from"]
end

God::Contacts::Email.defaults do |d|
  d.from_email = from_email
  d.from_name = 'Bixby Server God'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'support'
  c.to_email = from_email
end

%w{rvm puma sidekiq}.each do |file|
  God.load File.join(RAILS_ROOT, "config", "deploy", "god", "#{file}.god")
end
