
class Rest::Models::ScheduledCommandsController < ::Rest::BaseController

  def create
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
    reject_past = (params[:allow_past] == true)
    if t.nil? || !t.kind_of?(Time) || (t < now && reject_past) then
      return false
    end

    return [t, ChronicDuration.output((t-now).to_i, :format => :short)]
  end

end
