
class Rest::Models::ReposController < UiController

  def index
    restful Repo.where(:org_id => current_user.org_id)
  end

end
