
class TeamController < UiController

  def index
    bootstrap User.for_user(current_user).includes(:org, :roles, :user_permissions)
  end

  def show
    bootstrap User.includes(:org, :roles, :user_permissions).find(_id)
  end

end
