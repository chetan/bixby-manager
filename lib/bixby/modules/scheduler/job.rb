
module Bixby
class Scheduler

  # Describes a Job to be executed at a later time
  #
  # @!attribute [rw] klass
  #   @return [Class] class which contains the target method
  #
  # @!attribute [rw] method
  #   @return [Symbol] target method
  #
  # @!attribute [rw] args
  #   @return [Array] list of arguments to pass to method call. Objects should
  #                   be passed as basic types when possible. For example,
  #                   models can generally be passed as IDs (the method should
  #                   then do a lookup)
  class Job

    include Bixby::Log
    extend Bixby::Log

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

    # Returns arguments needed by perform for running this job
    def queue_args
      [@klass.to_s, @method.to_s] + @args
    end

  end

end # Scheduler
end # Bixby
