
namespace :misc do
  desc "get uname for each server"
  task :uname do
    on roles(:all) do |host|
      execute "uname -a"
    end
  end
end
