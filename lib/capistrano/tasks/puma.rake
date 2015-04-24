
namespace :puma do
  %w(start stop restart).each do |action|
    desc "#{action.capitalize} the Puma cluster"
    task action.to_sym do
      on roles(:web) do |host|
        execute :sudo, "/etc/init.d/bixby-server god #{action} puma"
      end
    end
  end
end
