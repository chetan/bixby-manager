
class MetricInfo < ActiveRecord::Base

  belongs_to :command

  def self.for(command, key)
    command = command.check.command if command.kind_of? Metric
    where(:command_id => command.id, :metric => key)
  end

  def to_api(opts={}, as_json=true)
    opts[:except] = [ :command_id ]
    super(opts, as_json)
  end

end
