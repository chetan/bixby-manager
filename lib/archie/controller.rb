
module Archie
  module Controller

    def is_logged_in?
      !session[:current_user].blank?
    end
    alias_method :is_authenticated?, :is_logged_in?

    def authenticate(username, password)
      user = User.find_by_username_or_email(username)
      if !user.blank? && user.valid_password?(password) then
        log_user_in(user)
        return user
      end
      return nil
    end

    def log_user_out
      session.delete(:current_user)
      opts = env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY]
      opts[:drop] = true if opts

      true
    end

    def log_user_in(user)
      session[:current_user] = user.id

      # recycle session id
      opts = env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY]
      opts[:renew] = true if opts

      # recycle csrf token
      session.delete(:_csrf_token)
      form_authenticity_token

      true
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
        # TODO invalidate session and return to login
      end
    end
  end
end
