
require 'net/ssh'

module Bixby
  module ApiView

    class Repo < ::ApiView::Base

      for_model ::Repo

      def self.convert(obj)

        hash = attrs(obj, :id, :name, :uri, :branch)
        hash[:org] = obj.org.blank? ? nil : obj.org.name
        hash[:tenant] = obj.org.blank? ? nil : obj.org.tenant.name

        # add public_key
        if not obj.public_key.blank? then
          hash[:public_key] = to_ssh_key(obj.private_key)
        end

        return hash
      end

      def self.to_ssh_key(key)
        key = OpenSSL::PKey::RSA.new(key)
        return "ssh-rsa " + [key.public_key.to_blob].pack("m0") + " bixby"
      end
    end # Repo

  end # ApiView
end # Bixby
