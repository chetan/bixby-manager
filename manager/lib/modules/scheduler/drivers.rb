
require 'modules/scheduler/driver'

module Scheduler

  class << self

    def drivers
      @drivers ||= []
    end

    def driver
      if @drivers.empty? then
        raise "No available drivers!"
      end
      @drivers.last
    end

  end

end
