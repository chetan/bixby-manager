
class Check < ActiveRecord::Base

  belongs_to :host
  belongs_to :agent
  belongs_to :command

  serialize :args, JSONColumn.new

  # Get a list of CommandMetrics that this check provides
  def metrics
    @metrics ||= MetricInfo.where("command_id = ?", self.command_id)
  end

end
