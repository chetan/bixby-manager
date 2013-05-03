
class Rest::Models::UsersController < UiController

  def index
    users = User.where(:org_id => current_user.org_id)
    restful users
  end

  def show
    user = User.find(_id)
    restful user
  end

  def update
  end

  def destroy
  end

end
