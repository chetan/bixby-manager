
class Rest::Models::TriggersController < ::Rest::ApiController

  # POST /rest/hosts/:host_id/triggers
  def create

    # Parameters:
    # {
    #   "host_id"   => "1",
    #   "metric"    => "hardware.cpu.loadavg.1m",
    #   "severity"  => "warning",
    #   "sign"      => "ge",
    #   "threshold" => "5",
    #   "status"    => ["WARNING", "UNKNOWN", "TIMEOUT"],
    # }

    options = pick(:host_id, :check_id, :metric_id, :severity, :sign, :threshold, :status)
    trigger = Bixby::Monitoring.new.add_trigger(options)

    restful trigger
  end

end
