
module Archie
  class SessionMiddleware < ActionDispatch::Session::ActiveRecordStore

    # Override to only commit (send a cookie header) if we currently have a logged in user
    # or we processing a logout
    def commit_session(env, status, headers, body)
      session = env[Rack::Session::Abstract::ENV_SESSION_KEY]
      logout = session.delete(:logout)
      if session[:current_user].blank? && !logout then
        return [status, headers, body]
      end

      status, headers, body = super
      if logout then
        # make sure the cookie gets destroyed
        ::Rack::Utils.delete_cookie_header!(headers, "_session_id")
      end
      return [status, headers, body]
    end

  end
end
