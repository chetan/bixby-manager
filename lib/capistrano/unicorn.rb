
if Object.const_defined? :Capistrano then

  namespace :unicorn do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the Unicorn cluster"
      task action.to_sym do
        run "#{sudo} god restart unicorn-bixby"
      end
    end
  end

end
