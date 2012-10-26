
class MetricInfo < ActiveRecord::Base

  belongs_to :command

  # Retrieve the MetricInfo for the given Command
  #
  # @param [Command] command
  # @param [String] key
  #
  # @return [MetricInfo]
  def self.for(command, key)
    if command.kind_of? Metric then
      command = command.check.command
      key = command.key
    elsif command.kind_of? Check then
      command = command.command
    end
    where(:command_id => command.id, :metric => key)
  end

end
