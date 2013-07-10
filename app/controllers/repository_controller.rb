
class RepositoryController < Repository::BaseController

  # /repository
  def index
    repos = Repo.for_org(current_user.org_id)
    bootstrap repos, :type => Repo

    commands = Command.for_repos(repos)
    bootstrap commands, :type => Command
  end

  def show
    repo = Repo.find(_id)
    bootstrap repo
    bootstrap Command.for_repos([repo]), :type => Command
  end

  def new
  end

end
