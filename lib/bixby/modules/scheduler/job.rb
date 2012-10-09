
module Bixby
class Scheduler

  class Job

    attr_accessor :klass, :method, :args

    def initialize(klass, method, args = [])
      @klass = klass
      @method = method
      @args = args
    end

    def self.perform(*args)
      klass = args.shift.constantize
      method = args.shift
      klass.new.send(method, *@args)
    end

    def queue_args
      [@klass.to_s, @method.to_s] + @args
    end

  end

end # Scheduler
end # Bixby
