
if Object.const_defined? :Capistrano then

  namespace :bixby do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the Bixby services"
      task action.to_sym do
        run "#{sudo} god #{action} bixby"
      end
    end
  end

end
