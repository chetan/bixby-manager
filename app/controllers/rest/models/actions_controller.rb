
class Rest::Models::ActionsController < ::Rest::ApiController

  def create

    # Parameters:
    # {"host_id"=>2, "trigger_id"=>4, "action_type"=>"alert", "target_id"=>"1"}

    opts = pick(:trigger_id, :action_type, :target_id)
    restful Bixby::Monitoring.new.add_trigger_action(opts)
  end

end
