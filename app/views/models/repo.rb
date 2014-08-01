
module Bixby
  module ApiView
    class Repo < ::ApiView::Base

      for_model ::Repo
      attrs :id, :name, :uri, :branch, :created_at, :updated_at

      def convert
        super

        self[:org]    = obj.org.blank? ? nil : obj.org.name
        self[:tenant] = obj.org.blank? ? nil : obj.org.tenant.name

        # add public_key
        if not obj.public_key.blank? then
          self[:public_key] = obj.ssh_public_key
        end

        self
      end

    end
  end
end
