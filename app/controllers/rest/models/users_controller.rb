
class Rest::Models::UsersController < ::Rest::ApiController

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

  def update
    user = User.find(_id)
    attrs = pick(:name, :username, :email, :phone, :password, :password_confirmation)
    user.update_attributes(attrs)
    restful user
  end

  def destroy
    # TODO
  end
end
