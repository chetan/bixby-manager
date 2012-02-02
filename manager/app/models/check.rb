
class Check < ActiveRecord::Base

  belongs_to :agent

  has_one :command
  has_one :resource

end
