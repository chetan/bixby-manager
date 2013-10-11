
class Rest::Models::AgentsController < ::Rest::ApiController

  def index
    restful Agent.where(:host_id => Host.for_user(current_user))
  end

  def show
    restful Agent.find(_id)
  end

end
