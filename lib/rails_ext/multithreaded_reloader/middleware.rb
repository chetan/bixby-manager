
module MultithreadedReloader
  class Middleware

    def initialize(app)
      @app = app
      @mutex = Mutex.new
      @last = 0
    end

    def call(env)

      if ! @listener then
        @listener = Listener.new
        @listener.start!

        # for load everything under app/
        # time = Time.new.to_i
        # dir = Rails.root.join("app", "**/*.rb").to_s
        # Dir.glob(dir) { |f| require f }
        # @last = time
      end

      return @app.call(env)
    end

  end
end
