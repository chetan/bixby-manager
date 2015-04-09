
class Rest::Models::UsersController < ::Rest::BaseController

  skip_before_filter :authenticate_user!, :only => [ :forgot_password, :reset_password,
                                                     :accept_invite ]

  def index
    restful User.for_user(current_user)
  end

  def show
    restful User.find(_id)
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
    restful user.valid_password?(params[:password])
  end

  def confirm_token
    user = User.find(_id)
    restful user.valid_otp?(params[:token])
  end

  def update
    user = User.find(_id)
    attrs = pick(:name, :username, :email, :phone, :password, :password_confirmation)
    if attrs[:password].blank? || attrs[:password_confirmation].blank? then
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end
    user.update_attributes(attrs)
    user.save!
    restful user
  end

  def destroy
    user = User.find(_id)
    if user.id == current_user.id then
      return render :json => {:success => false, :error => "can't delete self"}, :status => 400
    end

    user.destroy
    return render :json => {:success => true}
  end

  def assign_2fa_secret
    user = User.find(params['user_id'])
    user.otp_secret = User.generate_otp_secret
    user.save

    restful user.otp_secret
  end

  def enable_2fa
    user = User.find(params['user_id'])
    user.otp_required_for_login = true
    user.save

    restful user
  end

  def disable_2fa
    user = User.find(params['user_id'])
    user.otp_required_for_login = false
    user.otp_secret = nil
    user.save

    restful user
  end

  def forgot_password
    user = User.find_by_username_or_email(params[:username])
    if user.blank? then
      return render :json => {:success => false, :error => "unknown username or email address"}, :status => 400
    end

    # set token
    user.reset_password_token   = Archie.generate_token
    user.reset_password_sent_at = Time.new
    user.save

    Archie::Mail.forgot_password(user).deliver_later
    head 204
  end

  def reset_password
    user = User.where(:reset_password_token => params[:user][:token]).first
    if user.blank? then
      return render :json => {:success => false, :error => "invalid token"}, :status => 400
    end

    if user.reset_password_sent_at < (Time.new-3600*3) then
      # older than 3 hours
      return render :json => {:success => false, :error => "token expired"}, :status => 400
    end

    user.password               = params[:user][:password]
    user.password_confirmation  = params[:user][:password_confirmation]
    user.reset_password_token   = nil
    user.reset_password_sent_at = nil
    user.save!

    return render :json => {:success => true}
  end

  def create_invite
    user = User.new
    user.org_id = current_user.org_id
    user.email = params[:email]
    user.username = params[:username] || ""
    user.invite_token = Archie.generate_token
    user.invite_sent_at = user.invite_created_at = Time.new
    user.invited_by_id = current_user.id
    user.save!

    Token.create(user, "default")

    Archie::Mail.invite_user(user, current_user).deliver_later

    return render :json => {:success => true}
  end

  def accept_invite
    user = User.where(:invite_token => params[:user][:token]).first
    if user.blank? then
      return render :json => {:success => false, :error => "invalid token"}, :status => 400
    end

    if user.invite_sent_at < (Time.new-86400*2) then
      # older than 2 days
      return render :json => {:success => false, :error => "token expired"}, :status => 400
    end

    user.name                  = params[:user][:name]
    user.username              = params[:user][:username]
    user.password              = params[:user][:password]
    user.password_confirmation = params[:user][:password_confirmation]
    user.invite_accepted_at    = Time.new
    user.save

    return render :json => {:success => true}
  end

end
