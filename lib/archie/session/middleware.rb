
module Archie
  class Session < ActiveRecord::SessionStore::Session
    class Middleware < ActionDispatch::Session::ActiveRecordStore



      # private

      # def set_session(env, sid, session_data, options)
      #   Rails.logger.warn "set_session from archie.."
      #   if session_data[:current_user].blank? then
      #     Rails.logger.warn "current_user is blank"
      #     return sid # without saving
      #   end
      #   Rails.logger.warn "current_user is NOT blank"

      #   super # save the session
      # end


    end
  end
end
