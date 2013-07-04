
class Repository::BaseController < UiController

  # /repository
  def index
    repos = Repo.for_org(current_user.org_id)
    bootstrap repos, :type => Repo
  end

  def new
  end

end
