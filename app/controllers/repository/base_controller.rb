
class Repository::BaseController < UiController

  # /repository
  def index
    repos = Repo.where(:org_id => current_user.org_id)
    bootstrap repos, :type => Repo
  end

end
