
module Bixby
  module ApiView
    class User < ::ApiView::Base

      for_model ::User
      attributes :id, :username, :name, :email, :phone, :otp_required_for_login,
                 :created_at, :last_sign_in_at,
                 :invite_created_at, :invite_accepted_at, :invited_by_id

      def convert
        super
        self[:org]         = obj.org.name
        self[:tenant]      = obj.org.tenant.name
        self[:permissions] = render(obj.permissions)

        if obj.id == current_user.id then
          token = Token.where(:user_id => obj.id, :purpose => "default").first
          self[:install_token] = token.token
        end

        if obj.invited_by then
          self[:invited_by] = obj.invited_by.display_name
        end

        self
      end

    end
  end
end
