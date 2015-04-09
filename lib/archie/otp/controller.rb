
require "archie/config"

module Archie
  module OTP
    module Controller

      extend ActiveSupport::Concern

      AUTH_TOKEN_REQUIRED = 3

      # Override to add OTP check
      def authenticate(username, password)
        # do normal auth then check if token is enabled
        ret = super
        if ret == Archie::Controller::AUTH_SUCCESS && current_user.otp_required_for_login then
          session[:require_token] = Time.new
          return AUTH_TOKEN_REQUIRED
        end

        return ret
      end

      # Validate the given token
      def validate_token(token)
        token_date = session[:require_token]
        if current_user.blank? or token_date.blank? or token_date < (Time.new-300) then
          # invalidate session if:
          # * current_user missing or
          # * token timestamp is older than 5min
          Archie::Controller::AUTH_INVALID_SESSION

        elsif current_user.valid_otp?(token) then
          session.delete(:require_token)
          # track now that token has been verified
          current_user.update_tracked_fields!(request.remote_ip)
          current_user.save
          Archie::Controller::AUTH_SUCCESS

        else
          # token was not valid, auth failed
          if user then
            user.failed_attempts += 1
            user.save
          end
          Archie::Controller::AUTH_ERROR
        end
      end

      # Override to check for token validation
      def is_logged_in?
        super && !require_token?
      end

      # Check if we are at the token-verify login phase
      def require_token?
        !session[:require_token].blank?
      end

    end
  end
end
