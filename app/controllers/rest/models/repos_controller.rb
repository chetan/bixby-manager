
class Rest::Models::ReposController < UiController

  def index
    restful Repo.for_org(current_user.org_id)
  end

  # params:
  # {
  #   :name
  #   :uri
  #   :branch
  #   :requires_key
  # }
  def create

    attrs = pick(:name, :uri, :branch, :requires_key)
    attrs[:org_id] = current_user.org_id
    repo = Bixby::Repository.new.create(attrs)

    restful repo
  end

end
