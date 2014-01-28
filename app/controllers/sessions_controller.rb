
class SessionsController < Devise::SessionsController

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource

    # return the user object and a new csrf token
    ret = { :user => current_user, :csrf => form_authenticity_token }
    ret[:redir] = URI.parse(session.delete(:return_to)).path if session.include? :return_to

    if true_user.can?("impersonate_users")
      MultiTenant.with(nil){
        ret[:users] = User.all
        restful ret
      }
    else
      restful ret
    end
  end

  def destroy
    session[:impersonated_user_id] = nil # stop_impersonating_user() - method not avail here
    super
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed"]}, :status => 401
  end

end
