
class SessionsController < ApplicationController

  def create

    case authenticate(params[:user][:username], params[:user][:password])
    when AUTH_ERROR
      return error()

    when AUTH_TOKEN_REQUIRED
      return restful({ :token_required => true, :csrf => form_authenticity_token })

    when AUTH_SUCCESS
      return success()
    end

  end

  def verify_token
    token = params[:user][:token]
    if current_user.blank? then
      return error()
    end

    if validate_token(token) then
      return success()
    end

    return error()
  end

  def destroy
    session[:impersonated_user_id] = nil # stop_impersonating_user() - method not avail here
    log_user_out()
    return render :json => {:success => true}, :status => 200
  end


  private

  def success
    data = { :user => current_user, :csrf => form_authenticity_token }
    data[:redir] = URI.parse(session.delete(:return_to)).path if session.include? :return_to

    if current_user.can?("impersonate_users")
      MultiTenant.with(nil) {
        data[:users] = User.all
      }
    end
    return restful(data)
  end

  def error
    return render :json => {:success => false, :errors => ["Login failed"]}, :status => 401
  end

end
