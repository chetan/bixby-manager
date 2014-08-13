
module Archie
  class SessionMiddleware < ActionDispatch::Session::ActiveRecordStore

    def commit_session(env, status, headers, body)
      # ret = super
      # Rails.logger.warn "got back from super: " + ret.inspect
      # return ret

      Rails.logger.warn "commit_session from archie"
      session = env[Rack::Session::Abstract::ENV_SESSION_KEY]
      Rails.logger.warn "commit_session from archie " + session.to_hash.inspect
      if session[:current_user].blank? then
        Rails.logger.warn "current_user is BLANK!!!!!"
        return [status, headers, body]
      end

      ret = super(env, status, headers, body)
      Rails.logger.warn "got back from super: " + ret.inspect
      return ret
    end

  end
end
