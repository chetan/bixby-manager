
module Bixby
  class Scheduler

    class Deferrable

      def initialize(timestamp, clazz)
        @timestamp = timestamp
        @clazz = clazz
      end

      def method_missing(method, *args)
        job = Scheduler::Job.create(@clazz, method, args)
        Scheduler.new.schedule_at(@timestamp, job)
      end

    end

    module Defer

      def defer(delay=0)
        defer_at(Time.new+delay)
      end

      def defer_at(timestamp)
        clazz = self.kind_of?(Class) ? self : self.class
        Deferrable.new(timestamp, clazz)
      end

    end

  end

  class API
    include Scheduler::Defer
    extend Scheduler::Defer
  end
end

