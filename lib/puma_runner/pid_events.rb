
module PumaRunner
  class PidEvents < Puma::Events

    def initialize(stdout, stderr)
      super
      @formatter = lambda { |str| add_pid(add_ts(str)) }
    end

    def debug(str)
      log(format(str)) if @debug
    end



    private

    def add_pid(str)
      "#{$$} " + str.rstrip.gsub(/\n/, "\n#{$$} ")
    end

    def add_ts(str)
      t = Time.new.to_s
      if str.nil? or str.empty? then
        return "[#{t}]"
      end
      "[#{t}] " + str.rstrip.gsub(/\n/, "\n[#{t}] ")
    end

  end
end
