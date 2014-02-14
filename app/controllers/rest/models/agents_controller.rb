
class Rest::Models::AgentsController < ::Rest::ApiController

  def index
    restful Agent.where(:host_id => Host.for_user(current_user))
  end

  def show
    restful Agent.find(_id)
  end

  def update_check_config
    agent = Agent.find(_id)
    restful Bixby::Monitoring.new.update_check_config(agent)
  end

end
