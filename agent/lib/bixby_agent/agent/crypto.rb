
require 'ezcrypto'
require 'ezsig'

module Bixby
class Agent

module Crypto

  # create crypto keypair and save in config folder
  def create_keypair
    init_config_dir()
    pair = EzCrypto::Signer.generate
    File.open(private_key_file, 'w') { |out| out.write(pair.private_key.to_s) }
    File.open(public_key_file, 'w') { |out| out.write(pair.public_key.to_s) }
  end

  def private_key_file
    File.join(self.config_dir, "id_rsa")
  end

  def public_key_file
    File.join(self.config_dir, "id_rsa.pub")
  end

  def keypair
    @keypair ||= EzCrypto::Signer.from_file(private_key_file)
  end

  def public_key
    self.keypair.public_key.to_s
  end

  def private_key
    self.keypair.private_key.to_s
  end

end # Crypto

end # Agent
end # Bixby
