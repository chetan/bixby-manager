
class UiController < ApplicationController

  ensure_security_headers

  before_filter :login_required?
  before_filter :set_current_tenant


  # Placeholder route for simply returning bootstrap html
  def default
    render :index
  end


  protected

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

  def set_current_tenant
    MultiTenant.current_tenant = current_user.tenant if current_user
  end

  def login_required?
    if current_user and is_valid_session? then
      bootstrap current_user, :name => :current_user
      return false
    end

    # don't redirect when trying to login
    return false if params["controller"] == "sessions" && (params["action"] == "new" || params["action"] == "create")

    if request.xhr? or request.format != "text/html" then
      # return an error response instead
      return render :text => "not logged in", :status => 401
    end

    u = URI.parse(request.url)
    s = u.path
    s += "?" + u.query if u.query
    session[:return_to] = s

    qp = params.clone
    qp.delete(:controller)
    qp.delete(:action)
    path = params[:i].blank? ? login_path : login_path(qp)

    redirect_to path
  end

  # Test if the current session hash if valid
  def is_valid_session?
    session && session.include?("_csrf_token") && (current_user && session.include?("user_credentials"))
  end

end
