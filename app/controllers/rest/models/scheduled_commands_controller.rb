
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

    if t.nil? || !t.kind_of?(Time) || t < Time.new then
      return false
    end

    return [t, ChronicDuration.output((t-Time.new).to_i, :format => :short)]
  end

end
