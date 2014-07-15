
module MultithreadedReloader
  class Railtie < ::Rails::Railtie

    initializer 'multithreaded_reloader.init' do
      Listener.new.start!
    end

  end
end
