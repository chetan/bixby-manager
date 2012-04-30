
class CommandMetric < ActiveRecord::Base

  belongs_to :command

  def self.for(command)
    command = command.check.command if command.kind_of? Resource
    where("command_id = ?", command.id)
  end

  def to_api(opts, as_json=true)
    opts ||= {}
    opts[:except] = [ :command_id ]
    super(opts, as_json)
  end

end
