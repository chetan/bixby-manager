
require 'openssl'
require 'base64'

module Bixby
  class RemoteExec < API
    module Crypto

      # Encrypt data using the agent's public key
      #
      # @param [Agent] agent
      # @param [String] data    data to encrypt

      # @return [String] Base64 result
      def encrypt_for_agent(agent, data)
        # TODO replace master with server's hostname or per-tenant uuid?
        Bixby::CryptoUtil.encrypt(data, "master",
          public_key_for_agent(agent), server_key_for_agent(agent))
      end

      # Decrypt data that was encrypted with our public key
      #
      # @param [Agent] agent
      # @param [String] data    Base64 encoded data
      # @return [String] unencrypted data
      def decrypt_from_agent(agent, data)
        data = StringIO.new(data, 'rb')
        uuid = data.readline.strip
        Bixby::CryptoUtil.decrypt(data, server_key_for_agent(agent), public_key_for_agent(agent))
      end

      # Check whether crypto should be used or not. True if Rails.env is
      # "production" or crypto = true in bixby.yml
      #
      # @return [Boolean]
      def crypto_enabled?
        Rails.env == "production" || BIXBY_CONFIG[:crypto] == true
      end


      private

      # Get an Agent's known public key
      #
      # @param [Agent] agent
      #
      # @return [OpenSSL::PKey::RSA] public key file only
      def public_key_for_agent(agent)
        OpenSSL::PKey::RSA.new(agent.public_key)
      end

      # Get the server key for the given Agent
      #
      # @param [Agent] agent
      #
      # @return [OpenSSL::PKey::RSA] private key file
      def server_key_for_agent(agent)
        OpenSSL::PKey::RSA.new(agent.host.org.tenant.private_key)
      end

    end # Crypto
  end # RemoteExec
end # Bixby
