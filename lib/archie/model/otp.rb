
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

      module ClassMethods
        def generate_otp_secret(otp_secret_length = Archie::Config.otp_secret_length)
          ROTP::Base32.random_base32(otp_secret_length)
        end
      end

    end
  end
end
