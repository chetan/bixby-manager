
class SessionsController < ApplicationController

  def new(set_cookie=true)
    if is_logged_in? then
      return redirect_to default_url
    end
    set_csrf_cookie if set_cookie
    render :index
  end

  def create

    case authenticate(params[:username], params[:password])
    when AUTH_ERROR
      redirect_to "/login/fail"

    when AUTH_TOKEN_REQUIRED
      return redirect_to "/login/verify_token"

    when AUTH_SUCCESS
      redirect_to(session.delete(:return_to) || default_url)
    end

  end

  def verify_token_form
    new(false)
  end

  def verify_token
    token = params[:user][:token]
    if current_user.blank? then
      return token_error()
    end

    if validate_token(token) then
      return token_success()
    end

    return token_error()
  end

  def destroy
    session[:impersonated_user_id] = nil # stop_impersonating_user() - method not avail here
    log_user_out()
    return render :json => {:success => true}, :status => 200
  end


  private

  def default_url
    url_for(:inventory)
  end

  def token_success
    data = { :user => current_user, :csrf => form_authenticity_token }
    data[:redir] = session.delete(:return_to) if session.include? :return_to

    if current_user.can?("impersonate_users")
      MultiTenant.with(nil) {
        data[:users] = User.all
      }
    end
    return restful(data)
  end

  def token_error
    return render :json => {:success => false, :errors => ["Login failed"]}, :status => 401
  end

  # Override to also look for the csrf stored in an encrypted cookie
  def verified_request?
    super || validate_csrf_cookie
  end

end
