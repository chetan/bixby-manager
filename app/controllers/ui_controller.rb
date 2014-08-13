
class UiController < ApplicationController

  ensure_security_headers

  impersonates :user

  before_filter :authenticate_user!
  before_filter :set_current_tenant
  before_filter :bootstrap_current_user
  before_filter :bootstrap_users

  # Handle some common errors by simply redirecting to /inventory (for now)
  # TODO better handling
  rescue_from ActiveRecord::RecordNotFound, :with => :bail_from_ex
  rescue_from MultiTenant::AccessException, :with => :bail_from_ex

  # Helpers from Archie:
  #
  # is_logged_in?
  # current_user

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
    return if !true_user || !true_user.can?("impersonate_users")
    MultiTenant.with(nil) {
      bootstrap true_user, :name => :true_user
      bootstrap User.all.includes(:org, :roles, :user_permissions), :type => User
    }
  end

  def bail_from_ex(ex)
    # when catching MultiTenant::AccessException a response may already have been rendered
    # in that case, we need to override the response by nilling it out then redirecting
    self.response_body = nil
    logger.warn(ex_to_s(ex))
    redirect_to url_for(:inventory)
  end

  def ex_to_s(ex)
    params[:action] + "(#{params.inspect}) failed with #{ex.class}: #{ex.message}"
  end

  def authenticate_user!(opts={})
    return if is_logged_in?
    session[:return_to] = request.original_fullpath
    redirect_to "/login"
  end

end
