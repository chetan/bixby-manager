
class Rest::Models::UsersController < ::Rest::BaseController

  def index
    users = User.where(:org_id => current_user.org_id)
    restful users
  end

  def show
    user = User.find(_id)
    restful user
  end

  def valid
    u = params[:username]
    u.strip! if u
    if u.length <= 3 then
      restful({ :valid => false, :error => "too short" })
    elsif u !~ /^[a-zA-Z0-9_\-]+$/
      restful({ :valid => false, :error => "usernames may only contain alphanumeric characters plus _ and -" })
    elsif User.where(:username => u).blank? then
      restful({ :valid => true })
    else
      restful({ :valid => false, :error => "already taken" })
    end
  end

  def impersonate

    if !true_user.can?("impersonate_users") then
      return render :json => "denied", :status => 401
    end

    id = _id()
    if id == true_user.id then
      stop_impersonating_user
      set_current_tenant
      return restful(true_user)
    end

    u = nil
    MultiTenant.with(nil) do
      u = User.find(_id)
      impersonate_user(u)
      u.tenant
    end
    set_current_tenant # update it
    restful u
  end

  def confirm_password
    user = User.find(_id)
    pw   = SCrypt::Password.new(user.encrypted_password)
    pass = params[:password]

    ret  = (pw == sprintf("%s%s%s", pass, user.password_salt, Devise.pepper))
    restful ret
  end

  def update
    user = User.find(_id)
    attrs = pick(:name, :username, :email, :phone, :password, :password_confirmation)
    user.update_attributes(attrs)
    restful user
  end

  def assign_2fa_secret
    user = User.find(params['user_id'])
    user.send(:assign_auth_secret)
    user.save

    restful user.gauth_secret
  end

  def enable_2fa
    user = User.find(params['user_id'])
    user.gauth_enabled = true

    user.save

    restful user
  end

  def disable_2fa
    user = User.find(params['user_id'])
    user.gauth_enabled = false

    user.gauth_secret = nil
    user.save

    restful user
  end

  def destroy
    # TODO
  end
end
