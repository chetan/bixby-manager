
require 'find'
require 'digest'

require 'file_download'

class Provisioning < API

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
    return pret
  end

  # List files in bundle specified by CommandSpec
  #
  # @param [CommandSpec] command  Command/Bundle to list files for
  # @return [Array<Hash>] ret
  #   * :file [String] Relative path of file
  #   * :digest [String] SHA1 digest of file
  def list_files(command)

    command = create_spec(command)
    sha = Digest::SHA1.new

    files = []
    root = File.join(command.bundle_dir, "")
    Find.find(root) do |path|
      next if path == root or not File.file? path
      files << { :file => path.gsub(root, ""), :digest => sha.hexdigest(File.read(path)) }
    end

    return files
  end

  # Download the given command file
  #
  # @param [CommandSpec] command
  # @param [String] file  relative path to file
    # @return [FileDownload]
  def fetch_file(command, file)

    command = create_spec(command)
    path = File.join(command.bundle_dir, file)
    if File.file? path then
      return FileDownload.new(path)
    end

    return nil # TODO raise err
  end

end
