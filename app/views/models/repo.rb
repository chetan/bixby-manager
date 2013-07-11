
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
          hash[:public_key] = obj.ssh_public_key
        end

        return hash
      end
    end # Repo

  end # ApiView
end # Bixby
