
class Rest::Models::ActionsController < UiController

  def create

    # Parameters:
    # {"host_id"=>2, "trigger_id"=>4, "action_type"=>"alert", "target_id"=>"1"}

    opts = pick(:trigger_id, :action_type, :target_id)
    action = Bixby::Monitoring.new.add_trigger_action(opts)

    restful action
  end

end
