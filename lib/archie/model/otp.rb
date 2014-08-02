
require "archie/config"

module Archie
  module Model
    module OTP

      extend ActiveSupport::Concern

      included do
        attr_encrypted :otp_secret, :key  => Archie::Config.otp_secret_encryption_key,
                                    :mode => :per_attribute_iv_and_salt unless self.attr_encrypted?(:otp_secret)
        attr_accessor :otp_attempt
      end

      # Validate the given OTP code
      def valid_otp?(code)
        return false unless otp_secret.present?

        totp = self.otp(otp_secret)
        totp.verify_with_drift(code, Archie::Config.otp_allowed_drift)
      end

      def otp(otp_secret = self.otp_secret)
        ROTP::TOTP.new(otp_secret)
      end

      def current_otp
        otp.at(Time.now)
      end

      def otp_provisioning_uri(account, options = {})
        ROTP::TOTP.new(otp_secret, options).provisioning_uri(account)
      end

      module ClassMethods
        def generate_otp_secret(otp_secret_length = Archie::Config.otp_secret_length)
          ROTP::Base32.random_base32(otp_secret_length)
        end
      end

    end
  end
end
