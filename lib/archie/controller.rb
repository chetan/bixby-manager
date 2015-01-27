
module Archie
  module Controller

    extend ActiveSupport::Concern

    AUTH_INVALID_SESSION = -1
    AUTH_ERROR           = 0
    AUTH_SUCCESS         = 1
    AUTH_OK              = 1

    def is_logged_in?
      !session[:current_user].blank?
    end
    alias_method :is_authenticated?, :is_logged_in?

    def authenticate(username, password)
      user = User.find_by_username_or_email(username)
      if !user.blank? && user.valid_password?(password) then
        log_user_in(user)
        return AUTH_SUCCESS
      end
      return AUTH_ERROR
    end

    def log_user_out
      session[:logout] = true
      session.delete(:current_user)
      opts = env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY]
      opts[:drop] = true if opts

      true
    end

    def log_user_in(user)

      # update tokens
      if !user.otp_required_for_login then
        user.update_tracked_fields!(request.remote_ip)
        user.save
      end

      # store in session
      session[:current_user] = user.id
      @current_user = user

      # recycle session id
      opts = env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY]
      opts[:renew] = true if opts

      # recycle csrf token
      session.delete(:_csrf_token)
      form_authenticity_token

      true
    end

    def set_csrf_cookie
      real_csrf_token(session) # force token to get generated so we can use it
      cookies.encrypted[:csrf] = session[:_csrf_token]
    end

    def validate_csrf_cookie
      csrf = cookies.encrypted[:csrf]
      cookies.delete(:csrf)

      fake_session = { :_csrf_token => csrf } # use a fake session hash for the following method
      valid_authenticity_token?(fake_session, form_authenticity_param) ||
        valid_authenticity_token?(fake_session, request.headers['X-CSRF-Token'])
    end

  end
end

# Required by pretender
module ActionController
  class Base

    def current_user
      return @current_user if @current_user or session[:current_user].blank?
      begin
        id = session[:current_user]
        @current_user = User.find(id)
      rescue Exception => ex
        logger.warn "Failed to load logged in user with id '#{id}': #{ex.message}"
        log_user_out
        return redirect_to "/"
      end
    end

  end
end
