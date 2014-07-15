
module MultithreadedReloader

  PATHS = %w{app lib}

  # Reload all files in the given path if they have changed since the given timestamp
  #
  # @param [String] path
  # @param [Mutex] mutex           shared mutex to lock access to this method
  # @param [Fixnum] last
  def self.reload(path, mutex, last)
    mutex.synchronize {
      Logging.logger[self].warn "reloading changed file(s) in #{path}"

      files = []
      $".delete_if do |f|
        if f =~ /^#{path}/ && File.mtime(f).to_i > last then
          files << f
          true
        else
          false
        end
      end

      files.each { |f| require f }
    }
  end

end

require "rails_ext/multithreaded_reloader/listener"
require "rails_ext/multithreaded_reloader/middleware"
# require "rails_ext/multithreaded_reloader/railtie"
