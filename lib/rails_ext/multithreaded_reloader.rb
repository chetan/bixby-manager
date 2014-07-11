
class MultithreadedReloader

  PATHS = %w{app lib}

  def initialize(app)
    @app = app
    @mutex = Mutex.new
    @last = 0
    @started = false
    @listeners = []
  end

  def call(env)
      # reload_all
    start_listener if !@started
    @mutex.synchronize {
      # don't want any code reloading while our action is being called
      return @app.call(env)
    }
  end

  def start_listener
    return if @started

    ActionView::Resolver.caching = false

    paths = PATHS.map { |d| Rails.root.join(d).to_s }
    Logging.logger[self].warn "Starting MultiThreaded Reload Listener"
    Logging.logger[self].warn "watching paths: " + paths.inspect

    paths.each do |path|
      # not sure why i need to create a listener for each path..
      listener = Listen.to(path) do |mod, add, del|
        reload(mod + add)
      end
      listener.start
      @listeners << listener
    end
    @started = true
  end

  # Reload only the given files which are presumed to have changed
  def reload(files)
    @mutex.synchronize {
      Logging.logger[self].debug "reloading changed file(s): " + files.inspect
      files = files.map { |f| File.expand_path(f) }
      $".delete_if { |f| files.include? f }
      files.each { |f| require f }
    }
  end

  # Brute force reloader
  def reload_all
    @mutex.synchronize {
      Logging.logger[self].warn "reloading changed file(s)"
      time = Time.new.to_i

      PATHS.each do |dir|
        dir = Rails.root.join(dir)
        files = []
        $".delete_if do |f|
          if f =~ /^#{dir}/ && File.mtime(f).to_i > @last then
            files << f
            true
          else
            false
          end
        end

        files.each { |f| require f }
      end

      @last = time
    }
  end

end
