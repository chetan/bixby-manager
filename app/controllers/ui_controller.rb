
class UiController < ApplicationController
  before_filter :login_required?
  before_filter :apply_current_tenant

  def current_user
    # TODO replace with proper auth/session (authlogic?)
    return @current_user if not @current_user.nil?
    return nil if session[:logged_in].blank?
    @current_user = User.find(session[:logged_in])
  end

  def apply_current_tenant
    set_current_tenant(self.current_user.org.tenant)
  end

  def login_required?
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
