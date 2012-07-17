
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
        Base64.encode64(public_key_for_agent(agent).public_encrypt(data))
      end

      # Decrypt data that was encrypted with our public key
      #
      # @param [Agent] agent
      # @param [String] data    Base64 encoded data
      # @return [String] unencrypted data
      def decrypt_from_agent(agent, data)
        server_key_for_agent(agent).private_decrypt(Base64.decode64(data))
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
