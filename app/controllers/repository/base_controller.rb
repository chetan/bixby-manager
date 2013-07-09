
class Repository::BaseController < UiController

  # /repository
  def index
    repos = Repo.for_org(current_user.org_id)
    bootstrap repos, :type => Repo

    commands = Command.for_repos(repos)
    bootstrap commands, :type => Command
  end

  def new
  end

end
