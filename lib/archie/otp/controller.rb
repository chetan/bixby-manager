
require "archie/config"

module Archie
  module OTP
    module Controller

      extend ActiveSupport::Concern

      AUTH_TOKEN_REQUIRED = 3

      def authenticate(username, password)
        # do normal auth then check if token is enabled
        ret = super
        if ret == Archie::Controller::AUTH_SUCCESS && current_user.otp_required_for_login then
          session[:require_token] = true
          return AUTH_TOKEN_REQUIRED
        end

        return ret
      end

      def validate_token(token)
        if current_user.valid_otp?(token) then
          session.delete(:require_token)
          # track now that token has been verified
          current_user.update_tracked_fields!(request.remote_ip)
          current_user.save
          return true
        end
        return false
      end

      def is_logged_in?
        super && !require_token?
      end

      def require_token?
        session[:require_token] == true
      end

    end
  end
end
