# == Schema Information
#
# Table name: checks
#
#  id              :integer          not null, primary key
#  host_id         :integer          not null
#  agent_id        :integer          not null
#  command_id      :integer          not null
#  args            :text
#  normal_interval :integer
#  retry_interval  :integer
#  timeout         :integer
#  plot            :boolean
#  enabled         :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#


class Check < ActiveRecord::Base

  belongs_to :host
  belongs_to :agent
  belongs_to :command

  has_many :metrics

  multi_tenant :via => :host

  serialize :args, JSONColumn.new

  # Shortcut accessor for this Check's Org
  #
  # @return [Org]
  def org
    self.host.org
  end

  # Get a list of MetricInfo that this check provides
  def metric_infos
    @metric_infos ||= MetricInfo.where(:command_id => self.command_id)
  end

  def serializable_hash(opts={})
    hash = super
    hash[:name] = self.command.name
    return hash
  end

end
