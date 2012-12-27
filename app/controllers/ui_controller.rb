
class UiController < ApplicationController
  before_filter :login_required?
  before_filter :apply_current_tenant

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    UserSession.with_scope(:find_options => {:joins => :org}) do
      UserSession.find
    end

    @current_user_session = UserSession.find
  end

  def apply_current_tenant
    set_current_tenant(current_user.org.tenant) if not current_user.nil?
  end

  def login_required?
    if current_user
      bootstrap current_user, :name => :current_user
      return false
    end

    # don't redirect when trying to login
    return false if params["controller"] == "sessions" && %w{new create}.include?(params["action"])

    session[:return_to] = request.url
    qp = params.clone
    qp.delete(:controller)
    qp.delete(:action)
    path = params[:i].blank? ? login_path : login_path(qp)

    redirect_to path
  end
end
