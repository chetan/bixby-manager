
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
    if command.blank? or not(command.bundle_exists? and command.command_exists?) then
      # TODO better error handling
      raise "error: tried to provision invalid bundle or command" + (command ? "\n" + command.to_s : "")
    end

    commands = [ command ] + get_dependent_bundles(command).flatten
    commands.uniq{ |c| c.repo + "-" + c.bundle }.reverse!

    results = []
    commands.each do |command|
      spec = create_provision_command(command)
      ret = exec_api(agent, "shell_exec", spec)
      if ret.success? or ret.code != 404 then
        results << ret
        next
      end

      # system/provisioning bundle is out of date. try to update it
      if ret.message !~ /digest does not match \('(.*?)' !=/ then
        logger.warn { "provision failed with an unknown error: #{ret.message}"}
        return ret
      end

      logger.debug { "provision of #{command.bundle} failed, will try to provision system/provisioning first" }

      # fake the digest in the provision call
      fake_digest = $1
      spec_self = create_provision_command(spec)
      spec_self[:digest] = fake_digest
      ret = exec_api(agent, "shell_exec", spec_self)
      if not ret.success? then
        return ret # bail out. can't even provision ourselves!
      end

      if command.bundle == "system/provisioning" then
        logger.debug { "original bundle was system/provisioning; bailing out" }
        return ret
      end

      logger.debug { "system/provisioning updated! continuing with #{command.bundle}" }

      # finally, provision the real spec
      results << exec_api(agent, "shell_exec", spec)
    end

    return results.last # return the original package being provisioned
  end

  # Upgrade Bixby Agent on the given agent or host
  #
  # @param [Host] host      to upgrade
  #
  # @return [String]
  def upgrade_agent(host)
    agent = agent_or_host(host)
    command = CommandSpec.new(:repo => "vendor", :bundle => "system/provisioning",
                              :command => "upgrade_agent.sh", :args => "--beta")

    res = exec(agent, command)
    if res.success? && res.stdout.strip =~ /^bixby upgraded to (.*?)$/ then
      agent.version = $1
      agent.save
      return agent.version
    end

    return "failed"
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


  private

  def create_provision_command(command)
    noargs         = command.kind_of?(Hash) ? command.dup : command.to_hash
    noargs[:args]  = nil
    noargs[:stdin] = nil
    noargs[:env]   = nil

    CommandSpec.new({
      :repo    => "vendor",
      :bundle  => "system/provisioning",
      :command => "get_bundle.rb",
      :stdin   => noargs.to_json
    }).to_hash
  end

  # Get a list of dependent bundles, if any
  #
  # @param [CommandSpec] command
  #
  # @return [Array<CommandSpec>] list of required bundles
  def get_dependent_bundles(command)
    manifest = command.load_manifest
    return [] if manifest.blank?

    deps = manifest["requires"]
    return [] if deps.blank?

    ret = []
    deps.each do |bundle|
      # try to find the bundle
      # TODO only vendor for now
      spec = CommandSpec.new(:repo => "vendor", :bundle => bundle)
      ret << spec
      ret += get_dependent_bundles(spec) # recurse
    end

    return ret
  end

end

end # Bixby
