
class Check < ActiveRecord::Base

  belongs_to :resource
  belongs_to :agent
  belongs_to :command

  serialize :args, JSONColumn.new

end
