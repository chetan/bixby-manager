
%w{unicorn sidekiq}.each do |file|
  God.load File.join(File.expand_path(File.dirname(__FILE__)), "god", "#{file}.god")
end
