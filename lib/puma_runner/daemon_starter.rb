
module PumaRunner
  class DaemonStarter

    def initialize(dir, name)
      @filename = File.join(dir, name + ".starting")
    end

    # Check if the daemon should start
    #
    # @return [Boolean] true if the daemon should continue starting
    def can_start?
      FileUtils.touch(@filename)
      @file = File.new(@filename)
      if @file.flock(File::LOCK_EX|File::LOCK_NB) == false then
        return false
      end

      return true
    end

    def starting?
      File.exists?(@filename)
    end

    # Unlock and delete the .starting file
    def cleanup!
      begin
        @file.flock(File::LOCK_UN) # unlock
      rescue => ex
      end
      begin
        File.delete(@filename) if File.exists? @filename
      rescue => ex
      end
    end

  end # DaemonStarter
end # PumaRunner
