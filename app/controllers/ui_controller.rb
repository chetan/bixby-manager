
class UiController < ApplicationController

  ensure_security_headers

  before_filter :login_required?
  before_filter :set_current_tenant

  # Handle some common errors by simply redirecting to /inventory (for now)
  # TODO better handling
  rescue_from ActiveRecord::RecordNotFound, :with => :bail_from_ex
  rescue_from MultiTenant::AccessException, :with => :bail_from_ex


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
  # causes a deprecation warning in rails 4 - need an authlogic update
    @current_user_session = UserSession.find
  end

  def set_current_tenant
    MultiTenant.current_tenant = current_user.tenant if current_user
  end

  # Check for a valid user session
  #
  # @return [Boolean] true if the request is not authenticated (user must login)
  def login_required?

    # check for user session
    if current_user and is_valid_session? then
      bootstrap current_user, :name => :current_user
      return false
    end

    # don't redirect when trying to login
    return false if params["controller"] == "sessions" && (params["action"] == "index" || params["action"] == "create")

    # render a response directly
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
    path = params[:i].blank? ? login_index_path : login_index_path(qp)

    redirect_to path
  end

  # Test if the current session hash if valid
  def is_valid_session?
    session && session.include?("_csrf_token") && (current_user && session.include?("user_credentials"))
  end

  def bail_from_ex(ex)
    logger.warn(ex_to_s(ex))
    redirect_to url_for(:inventory)
  end

  def ex_to_s(ex)
    params[:action] + "(#{params.inspect}) failed with #{ex.class}: #{ex.message}"
  end

end
