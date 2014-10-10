
class Rest::Models::ScheduledCommandsController < ::Rest::BaseController

  def index
    restful ScheduledCommand.for_user(current_user).
      where("schedule_type = 1 OR completed_at IS NULL").
      order(:created_at => :asc)
  end

  def history
    restful ScheduledCommand.for_user(current_user).
      where("schedule_type = 2 AND completed_at IS NOT NULL").
      order(:created_at => :asc)
  end

  def show
    restful ScheduledCommand.find(_id)
  end

  def create
    sc = ScheduledCommand.new

    host_ids = _array(:hosts).map { |i| i.to_i }.reject{ |s| s <= 0 }
    sc.agent_ids     = Agent.where(:host_id => host_ids).map { |a| a.id }.join(",")
    sc.command_id    = params[:command_id]
    sc.org_id        = current_user.org_id
    sc.created_by    = current_user.id
    sc.stdin         = params[:stdin]
    sc.args          = params[:args]
    sc.env           = params[:env]

    if params[:schedule_type].kind_of? Fixnum then
      sc.schedule_type = params[:schedule_type]
    else
      sc.schedule_type = ScheduledCommand::ScheduleType[params[:schedule_type]]
      # TODO raise if nil?
    end

    sc.schedule      = params[:schedule] if sc.cron?
    sc.scheduled_at  = Time.parse(params[:scheduled_at]) if params[:scheduled_at]
    sc.update_next_run_time!

    # set alert_on bitfield from array of statuses
    if params[:alert_on] != 0 then
      _array(:alert_on).each { |a| sc.send("alert_on_#{a}=".to_sym, true) }
      sc.alert_users = _array(:alert_users).map{ |s| s.to_i }.reject{ |s| s <= 0 }.sort.uniq.join(",")
      sc.alert_emails = params[:alert_emails]
    end

    sc.schedule_job!
    sc.save!

    true
  end

  def disable
    sc = ScheduledCommand.find(_id)
    if !sc.enabled then
      return sc
    end
    sc.disable!
    sc.save!

    sc
  end

  def enable
    sc = ScheduledCommand.find(_id)
    if sc.enabled then
      return sc
    end
    sc.enable!
    sc.save!

    sc
  end

  def destroy
    sc = ScheduledCommand.find(_id)
    sc.disable!
    sc.destroy!
    true
  end

  def validate

    t = nil
    if params[:type] == 'cron' then
      begin
        t = CronParser.new(params[:string]).next()
      rescue ArgumentError
      end

    elsif params[:type] == 'natural' then
      t = Chronic.parse(params[:string])
    end

    now = Time.new
    reject_past = (params[:allow_past] == "false")
    if t.nil? || !t.kind_of?(Time) || (t < now && reject_past) then
      return false
    end

    return [t, ChronicDuration.output((t-now).to_i, :format => :short)]
  end

end
