# == Schema Information
#
# Table name: metric_infos
#
#  id         :integer          not null, primary key
#  command_id :integer          not null
#  metric     :string(255)      not null
#  unit       :string(255)
#  desc       :string(255)
#  label      :string(255)
#  name       :string(255)
#


class MetricInfo < ActiveRecord::Base

  belongs_to :command

  multi_tenant :via => :command

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
