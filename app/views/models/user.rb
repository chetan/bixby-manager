
module Bixby
  module ApiView
    class User < ::ApiView::Base

      for_model ::User
      attributes :id, :username, :name, :email, :phone, :otp_required_for_login

      def convert
        super
        self[:org]         = obj.org.name
        self[:tenant]      = obj.org.tenant.name
        self[:permissions] = render(obj.permissions)
        self
      end

    end
  end
end
