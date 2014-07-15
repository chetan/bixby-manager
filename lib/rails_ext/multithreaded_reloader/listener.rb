
module MultithreadedReloader
  class Listener

    def initialize
      @mutex = Mutex.new
      @listeners = []
    end

    def start!
      ActionView::Resolver.caching = false

      paths = PATHS.map { |d| Rails.root.join(d).to_s }
      Logging.logger[self].warn "Starting MultiThreaded Reload Listener in process #{Process.pid}"
      Logging.logger[self].warn "watching paths: " + paths.inspect

      paths.each do |path|
        # not sure why i need to create a listener for each path..
        listener = Listen.to(path) do |mod, add, del|
          begin
            reload(mod + add)
          rescue Exception => ex
            Logging.logger[self].error "Caught while reloading: #{ex.message}"
          end
        end
        listener.start
        @listeners << listener
      end
      @started = true
    end

    # Reload only the given files which are presumed to have changed
    def reload(files)
      @mutex.synchronize {
        files = files.map { |f| File.expand_path(f) }.grep(/\.rb$/)
        return if files.empty?
        Logging.logger[self].debug "reloading changed file(s): " + files.inspect
        $".delete_if { |f| files.include? f }
        files.each { |f| require f }
      }
    end

  end

end
