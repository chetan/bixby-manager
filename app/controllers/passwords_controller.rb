
class PasswordsController < UiController # Devise::PasswordsController

  # POST /resource/password
  def create
    self.resource = User.find_by_username_or_email(params[:username])
    if self.resource.blank? then
      return render :text => "not found", :status => 400
    end
    self.resource.send_reset_password_instructions()

    if successfully_sent?(resource)
      head 204
    else
      render :text => "not found", :status => 400
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      sign_in(resource_name, resource)
      puts "sending 303"
      redirect_to root_path, :status => 303
    else
      render :json => {:errors => resource.errors}, :status => 400
    end
  end

end
