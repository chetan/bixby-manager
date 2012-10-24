
class Check < ActiveRecord::Base

  belongs_to :host
  belongs_to :agent
  belongs_to :command

  has_many :metrics

  serialize :args, JSONColumn.new

  # Shortcut accessor for this Check's Org
  #
  # @return [Org]
  def org
    self.host.org
  end

  # Shortcut accessor for this Check's Tenant
  #
  # @return [Tenant]
  def tenant
    self.org.tenant
  end

  # Get a list of MetricInfo that this check provides
  def metrics
    @metrics ||= MetricInfo.where("command_id = ?", self.command_id)
  end

  def serializable_hash(opts={})
    hash = super
    hash[:name] = self.command.name
    return hash
  end

end
