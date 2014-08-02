
require "archie/model/otp"

module Archie
  module Model

    extend ActiveSupport::Concern

    included do
      attr_reader :password, :current_password
      attr_accessor :password_confirmation

      validates_presence_of     :password
      validates_confirmation_of :password
      validates_length_of       :password, :minimum => 8
    end

    def valid_password?(pass)
      SCrypt::Password.new(self.encrypted_password) == sprintf("%s%s%s", pass, self.password_salt, Archie::Config.pepper)
    end

    def password=(new_password)
      self.password_salt = self.class.generate_password_salt if new_password.present?
      @password = new_password
      self.encrypted_password = password_digest(@password) if @password.present?
    end

    def password_confirmation=(new_password_confirmation)
      @password_confirmation = new_password_confirmation
    end

    def skip_confirmation!
      # TODO - this is supposed to skip sending confirmation/email validation emails
      #        in devise. probably remove it..
    end


    private

    def password_digest(password)
      SCrypt::Password.create("#{@password}#{password_salt}#{Archie::Config.pepper}").to_s
    end

    module ClassMethods
      def generate_password_salt
        SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') # borrowed from devise
      end
    end

  end
end
