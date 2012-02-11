
require 'find'
require 'digest'

require 'file_download'

module Provisioning

  include RemoteExec

  class << self

    # Manager API
    def provision(agent, command)

      command = create_spec(command)

      if not (command.bundle_exists? and command.command_exists?) then
        # complain
        raise "hey! *WE* don't even have that command!"
      end

      noargs = command.dup
      noargs.args = nil
      noargs.env = nil

      provision = CommandSpec.new({
                    :repo => "local", # only command that exists in "local" repo
                    :bundle => "system/provisioning", :command => "get_bundle.rb",
                    :stdin => noargs.to_json })

      pret = agent.run_cmd(provision)
      p pret
      return pret

    end

    # returns an array of hashes: [{ :file, :sha1 }]
    def list_files(request, params)

      cmd = CommandSpec.from_json(params)
      sha = Digest::SHA1.new

      files = []
      root = File.join(cmd.bundle_dir, "")
      Find.find(root) do |path|
        next if path == root or not File.file? path
        files << { :file => path.gsub(root, ""), :sha1 => sha.hexdigest(File.read(path)) }
      end

      return files
    end

    def fetch_file(request, params)

      cmd = CommandSpec.from_json(params["cmd"])
      file = params["file"]

      path = File.join(cmd.bundle_dir, file)
      if File.file? path then
        return FileDownload.new(path)
      end

      return nil
    end

  end

end
