
module PumaRunner

  class Pid

    attr_reader :pid_file, :pid_dir

    # Check if the given PID is running
    #
    # Borrowed from 'daemons' gem
    #
    # @param [Fixnum] pid
    #
    # @return [Boolean] true if running
    def self.running?(pid)
      return false unless pid

      # Check if process is in existence
      # The simplest way to do this is to send signal '0'
      # (which is a single system call) that doesn't actually
      # send a signal
      begin
        Process.kill(0, pid)
        return true
      rescue Errno::ESRCH
        return false
      rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
        return true
      end
    end

    def initialize(file)
      @pid_file = file
      @pid_dir = File.dirname(file)
    end

    # Read the current PID file
    #
    # @return [Fixnum] pid
    def read
      return nil if not exists?
      pid = File.read(@pid_file)
      return nil if pid.nil? or pid.empty?
      return pid.strip.to_i
    end

    # Write out our PID
    def write
      ensure_pid_dir()
      File.open(@pid_file, 'w'){ |f| f.write(Process.pid) }
    end

    def delete
      File.unlink(@pid_file)
    end

    # Check if the PID in this file is running
    #
    # return [Boolean] true if running
    def running?
      pid = read()
      return false if pid.nil?
      return Pid.running?(pid)
    end

    # Check if PID file exists
    #
    # @return [Boolean] true if exists
    def exists?
      File.exists?(@pid_file)
    end

    # Check if the PID given in the file is ours
    #
    # @return [Boolean] true if our own pid
    def ours?
      read() == Process.pid
    end

    # Make sure PID file dir exists
    def ensure_pid_dir
      if not File.directory? @pid_dir then
        FileUtils.mkdir_p(@pid_dir)
      end
    end

    # Use 'ps' to find running server processes
    def ps
      `ps auxwww | grep -v grep | grep 'puma: server'`.split(/\n/)
    end

    # Return list of all running server processes found using 'ps'
    def find
      ps.map{ |s| s.split(/\s+/)[1].strip.to_i }
    end

  end

end
