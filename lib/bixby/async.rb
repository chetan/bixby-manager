
module Bixby

  class << self

    attr_reader :async

    # Check whether the given module method should be handled asynchronously
    #
    # @param [Class] klass                module class
    # @param [Symbol] method              method
    #
    # @return [Boolean] true if it should be handled asynchronously
    def is_async?(klass, method)
      @async ||= {}
      klass = klass.to_s
      method = method.to_sym
      @async[klass] && @async[klass][method]
    end

    # Define the given method as asynchronous
    #
    # @param [Class] klass                module class
    # @param [Symbol] method              method
    def set_async(klass, method)
      @async ||= {}
      klass = klass.to_s
      method = method.to_sym
      if not @async.include? klass then
        @async[klass] = {}
      end
      @async[klass][method] = 1
    end

    # Submit the method call for immediate async execution via Bixby::Scheduler
    #
    # @param [Class] klass                module class
    # @param [Symbol] method              method
    # @param [Array] args                 Array or method params
    def do_async(klass, method, args)
      args = [ args ] if not args.kind_of? Array
      job = Bixby::Scheduler::Job.new(klass, method, args)
      Bixby::Scheduler.new.schedule_in(0, job)
    end

  end

end
