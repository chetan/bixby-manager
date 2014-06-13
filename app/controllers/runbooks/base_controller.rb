
class Runbooks::BaseController < Repository::BaseController

  # /runbooks
  def index
    repos = Repo.for_org(current_user.org_id)
    commands = Command.for_repos(repos)
    bootstrap commands, :type => Command

    hosts = Host.all_for_user(current_user)
    bootstrap hosts, :type => Host
  end

end
