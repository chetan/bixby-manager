
module Bixby
class Agent

module Crypto

  # create crypto keypair and save in config folder
  def create_keypair
    init_config_dir()
    pair = OpenSSL::PKey::RSA.generate(2048)
    File.open(private_key_file, 'w') { |out| out.write(pair.to_s) }
  end

  def private_key_file
    File.join(self.config_dir, "id_rsa")
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(File.read(private_key_file))
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
