
class ScheduledCommand < ActiveRecord::Base

  belongs_to :org
  belongs_to :agent
  belongs_to :command
  belongs_to :user, :foreign_key => :created_by
  belongs_to :command_log

  module ScheduleType
    CRON = 1
    ONCE = 2
  end
  Bixby::Util.create_const_map(ScheduleType)

end
