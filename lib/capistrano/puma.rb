
if Object.const_defined? :Capistrano then

  namespace :puma do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the Puma cluster"
      task action.to_sym do
        run "#{sudo} god #{action} puma"
      end
    end
  end

end
