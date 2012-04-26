
class CommandMetric < ActiveRecord::Base

  belongs_to :command

  def for(command)
    where("command_id = ?", command.id)
  end

end
