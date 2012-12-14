
%w{unicorn.god sidekiq.god}.each do |file|
  God.load File.join(File.expand_path(File.dirname(__FILE__)), file)
end
