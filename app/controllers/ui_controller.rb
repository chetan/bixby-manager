
class UiController < ApplicationController

  ensure_security_headers

  impersonates :user

  before_filter :authenticate_user!
  before_filter :set_current_tenant
  before_filter :bootstrap_current_user
  before_filter :bootstrap_users
  around_action :always_render_index

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

  # Override method from ActionController::ImplicitRender which will always try to render a template
  # when returning from a controller action. We handle it below in #restful_response instead.
  def default_render(*args)
    # no-op
  end

  def always_render_index
    res = yield
    if performed? then
      return res
    end
    render :index
  end

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
      bootstrap User.all.includes(:org, :roles, :user_permissions), :type => User, :name => "all_users"
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

    if request.xhr? then
      return render(:text => {:error => "not logged in"}, :as => :json, :status => 401)
    end

    # handle based on mime type
    respond_to do |format|
      format.html {
        # handle unathenticated user requesting an html page
        url = request.original_fullpath
        if url != "/" && url !~ %r{^/login} then
          cookies[:return_to] = request.original_fullpath
        end
        set_csrf_cookie
        render :index # let stark handle the redirect to login
      }

      # unauthenticated access to REST API endpoint
      format.any(:xml, :json) { render(:text => {:error => "not logged in"}, :as => :json, :status => 401) }
    end

  end

end
