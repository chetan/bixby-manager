
require 'find'
require 'digest'

require 'bixby/file_download'

module Bixby

class Provisioning < API

  # Provision an Agent with the given Command
  #
  # @param [Agent] agent
  # @param [CommandSpec] command
  # @return [JsonResponse] response for the provision request
  def provision(agent, command)

    command = create_spec(command)

    if not (command.bundle_exists? and command.command_exists?) then
      # TODO complain
      raise "hey! *WE* don't even have that command!"
    end

    noargs = command.dup
    noargs.args = nil
    noargs.env = nil

    provision = CommandSpec.new({
                  :repo => "vendor",
                  :bundle => "system/provisioning",
                  :command => "get_bundle.rb",
                  :stdin => noargs.to_json })

    return exec_api(agent, "exec", provision.to_hash)
  end

  # List files in bundle specified by CommandSpec
  #
  # @param [CommandSpec] command  Command/Bundle to list files for
  # @return [Array<Hash>] ret
  #   * file [String] Relative path of file
  #   * digest [String] SHA256 digest of file
  def list_files(command)
    command = create_spec(command)
    return command.load_digest["files"]
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

end # Bixby
