
require 'systemu'

module Bixby
class Agent

module RemoteExec

  # Shell exec a local command with the given params
  #
  # @param [Hash] params                  CommandSpec hash
  # @option params [String] :repo
  # @option params [String] :bundle
  # @option params [String] :command
  # @option params [String] :args
  # @option params [String] :stdin
  # @option params [String] :digest       Expected bundle digest
  # @option params [Hash] :env            Hash of extra ENV key/values to pass to sub-shell
  #
  # @return [Array<FixNum, String, String>] status code, stdout, stderr
  def exec(params)
    @log.debug{ "exec: #{params}" }

    digest = params.delete("digest") || params.delete(:digest)

    cmd = CommandSpec.new(params)
    cmd.validate()
    if digest and cmd.digest != digest then
      raise BundleNotFound, "digest does not match", caller
    end

    ret = cmd.execute()
    @log.debug{ "ret: " + MultiJson.dump(ret) }
    return ret
  end

end # RemoteExec

end # Agent
end # Bixby
