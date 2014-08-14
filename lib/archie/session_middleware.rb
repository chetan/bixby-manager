
module Archie
  class SessionMiddleware < ActionDispatch::Session::ActiveRecordStore

    # Override to only commit (send a cookie) if we currently have a logged in user
    # or we processing a logout
    def commit_session(env, status, headers, body)
      session = env[Rack::Session::Abstract::ENV_SESSION_KEY]
      if session[:current_user].blank? && !session.delete(:logout) then
        return [status, headers, body]
      end

      super
    end

  end
end
