
class SessionsController < ApplicationController

  def create

    user = authenticate(params[:user][:username], params[:user][:password])
    if user.blank? then
      return failure()
    end

    ret = { :user => user, :csrf => form_authenticity_token }
    ret[:redir] = URI.parse(session.delete(:return_to)).path if session.include? :return_to

    if user.can?("impersonate_users")
      MultiTenant.with(nil){
        ret[:users] = User.all
      }
    end
    return restful(ret)










    if resource.respond_to?(:get_qr) and resource.gauth_enabled? and resource.require_token?(cookies.signed[:gauth]) #Therefore we can quiz for a QR
      tmpid = resource.assign_tmp #assign a temporary key and fetch it
      warden.logout #log the user out

      #we head back into the checkga controller with the temporary id
      #Because the model used for google auth may not always be the same, and may be a sub-model, the eval will evaluate the appropriate path name
      #This change addresses https://github.com/AsteriskLabs/devise_google_authenticator/issues/7
      # respond_with resource, :location => eval("#{resource.class.name.singularize.underscore}_checkga_path(id:'#{tmpid}')")

      ret = { :tmpid => tmpid }
      restful ret

    else #It's not using, or not enabled for Google 2FA, OR is remembering token and therefore not asking for the moment - carry on, nothing to see here.
      sign_in_and_redirect(resource_name, resource)
    end

  end

  def update
    resource = resource_class.find_by_gauth_tmp(params[resource_name]['tmpid'])

    if not resource.nil?

      if resource.validate_token(params[resource_name]['gauth_token'].to_i)
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name,resource)
        warden.manager._run_callbacks(:after_set_user, resource, warden, {:event => :authentication})
        # respond_with resource, :location => after_sign_in_path_for(resource)

        if not resource.class.ga_remembertime.nil?
          cookies.signed[:gauth] = {
            :value => resource.email << "," << Time.now.to_i.to_s,
            :secure => !(Rails.env.test? || Rails.env.development?),
            :expires => (resource.class.ga_remembertime + 1.days).from_now
          }
        end

        # return the user object and a new csrf token
        ret = { :user => current_user, :csrf => form_authenticity_token }
        ret[:redir] = URI.parse(session.delete(:return_to)).path if session.include? :return_to

        if current_user.can?("impersonate_users")
          MultiTenant.with(nil){
            ret[:users] = User.all
            restful ret
          }
        else
          restful ret
        end
      else
        set_flash_message(:error, :error)
        redirect_to :root
      end

    else
      set_flash_message(:error, :error)
      redirect_to :root
    end
  end

  def destroy
    session[:impersonated_user_id] = nil # stop_impersonating_user() - method not avail here
    log_user_out()
    return render :json => {:success => true}, :status => 200
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed"]}, :status => 401
  end

end
