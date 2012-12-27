
module Bixby
  module ApiView

    class User < ::ApiView::Base

      for_model ::User

      def self.convert(obj)

        hash = attrs(obj, :id, :username, :name, :email, :phone)
        hash[:org] = obj.org.name

        return hash
      end

    end # Host

  end # ApiView
end # Bixby
