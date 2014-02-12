
class UiController < ApplicationController

  ensure_security_headers

  impersonates :user

  before_filter :authenticate_user!
  # before_filter :login_required?
  before_filter :set_current_tenant
  before_filter :bootstrap_current_user
  before_filter :bootstrap_users

  # Handle some common errors by simply redirecting to /inventory (for now)
  # TODO better handling
  rescue_from ActiveRecord::RecordNotFound, :with => :bail_from_ex
  rescue_from MultiTenant::AccessException, :with => :bail_from_ex

  # Helpers from Devise:
  #
  # user_signed_in?
  # current_user
  # user_session
  alias_method :current_user_session, :user_session

  # Helpers from pretender:
  #
  # true_user                 # returns authenticated user
  # impersonate_user(user)    # allows you to login as another user
  # stop_impersonating_user   # become yourself again


  # Placeholder route for simply returning bootstrap html
  def default
    render :index
  end


  protected

  def set_current_tenant
    if current_user.kind_of?(User) && current_user.can?("impersonate_users") then
      MultiTenant.current_tenant = MultiTenant.with(nil) { current_user.tenant }
    else
      MultiTenant.current_tenant = current_user.tenant if current_user
    end
  end

  def bootstrap_current_user
    if current_user then
      bootstrap current_user, :name => :current_user
    end
    true
  end

  # Bootstrap objects used for impersonation
  def bootstrap_users
    return if !true_user.can?("impersonate_users")
    MultiTenant.with(nil) {
      bootstrap true_user, :name => :true_user
      bootstrap User.all, :type => User
    }
  end

  # Check for a valid user session
  #
  # @return [Boolean] true if the request is not authenticated (user must login)
  def login_required?

    # check for user session
    if current_user and user_signed_in? then
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

  def bail_from_ex(ex)
    logger.warn(ex_to_s(ex))
    redirect_to url_for(:inventory)
  end

  def ex_to_s(ex)
    params[:action] + "(#{params.inspect}) failed with #{ex.class}: #{ex.message}"
  end

end
