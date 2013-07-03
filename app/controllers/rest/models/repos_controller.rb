
class Rest::Models::ReposController < UiController

  def index
    restful Repo.for_org(current_user.org_id)
  end

end
