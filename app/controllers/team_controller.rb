
class TeamController < UiController

  def index
    bootstrap User.for_user(current_user).includes(:org, :roles, :user_permissions)
  end

end
