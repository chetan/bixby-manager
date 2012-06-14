
require 'systemu'

module Bixby
class Agent

module RemoteExec

  # params hash contains:
  #   repo
  #   bundle
  #   command
  #   args (optional)
  #   env (optional)
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
