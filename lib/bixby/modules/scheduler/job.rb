
module Bixby
class Scheduler

  # Describes a Job to be executed at a later time
  #
  # @!attribute [rw] klass
  #   @return [Class] class which contains the target method
  # @!attribute [rw] method
  #   @return [Symbol] target method
  # @!attribute [rw] args
  #   @return [Array] list of arguments to pass to method call
  class Job

    attr_accessor :klass, :method, :args

    def self.create(klass, method, args = [])
      job = new
      job.klass = klass
      job.method = method
      job.args = args.kind_of?(Array) ? args : [args]

      return job
    end

    # Empty constructor for use by scheduling libraries (sidekiq)
    def initialize
    end

    # Called by Resque worker. Expects as input the output of #queue_args
    def self.perform(*args)
      klass = args.shift.constantize
      method = args.shift
      klass.new.send(method, *args)
    end

    # Returns arguments for use by Resque
    def queue_args
      [@klass.to_s, @method.to_s] + @args
    end

  end

end # Scheduler
end # Bixby
