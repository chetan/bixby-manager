
module Monitoring

  include RemoteExec

  GET_OPTIONS = "--options"

  class << self


    # Agent API
    def get_command_options(agent, command)

      #c = CommandSpec.new({ :repo => "vendor", :bundle => "baz", :command => "ls", :args => "/tmp" })
      return exec_mon(agent, command, GET_OPTIONS)
    end

    private

    # run with wrapper cmd
    def exec_mon(agent, command, args)

      command = create_spec(command)

      cmd = CommandSpec.new(:repo => "vendor",
              :bundle => "system/monitoring",
              :args => args + " " + File.join(command.relative_path, "bin", command.command))

      lang = "ruby"
      if command.command =~ /\.rb$/ then
        lang = "ruby"
      end
      cmd.command = "#{lang}_wrapper.rb"

      p cmd
      puts cmd.bundle_dir
      puts cmd.relative_path
      puts cmd.command_file
      cmd.validate

      # exit

      return exec(agent, cmd)
    end

  end

end
