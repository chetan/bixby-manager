
begin
  require 'resque_scheduler/tasks'
  task "resque:setup" => :environment
rescue LoadError
end
