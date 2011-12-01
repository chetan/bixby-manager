
module Scheduler

  class Job

    attr_accessor :name, :args

    def initialize(name, args = nil)
      @name = name
      @args = args
    end

  end

end
