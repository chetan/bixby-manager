
require "archie/config"
require "archie/model"
require "archie/controller"
require "archie/otp"
require "archie/mail"

module Archie
  class << self

    # Generate a friendly string randomly to be used as token.
    # Borrowed from devise
    def generate_token
      SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end

  end
end
