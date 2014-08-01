
module Archie
  module Model

    extend ActiveSupport::Concern

    included do
      validates_presence_of     :password
      validates_confirmation_of :password
      validates_length_of       :password, :minimum => 8
    end

    def valid_password?(pass)
      puts self.password_salt
      puts Archie::Config.pepper
      pw  = SCrypt::Password.new(self.encrypted_password)
      ret = (pw == sprintf("%s%s%s", pass, self.password_salt, Archie::Config.pepper))
    end

    # def set_password()
    #   SCrypt::Password.create("#{password}#{salt}#{pepper}").to_s
    # end

  end
end
