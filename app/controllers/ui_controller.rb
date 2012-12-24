
class UiController < ApplicationController
  before_filter :login_required

  def current_user
    # if session[:logged_in] == true then
    #   return true
    # end
    return nil
  end

  def login_required
    if not current_user.nil?
      # return show_logged_in_user_notifications
      return
    end

    # don't redirect when trying to login
    return if params["controller"] == "sessions" && %w{new create}.include?(params["action"])

    session[:return_to] = request.url
    qp = params.clone
    qp.delete(:controller)
    qp.delete(:action)
    path = params[:i].blank? ? login_path : login_path(qp)

    redirect_to path
  end
end
