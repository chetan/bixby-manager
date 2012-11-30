
namespace :misc do
  desc "get uname for each server"
  task :uname do
    run "uname -a"
  end
end
