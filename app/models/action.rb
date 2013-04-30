# == Schema Information
#
# Table name: actions
#
#  id          :integer          not null, primary key
#  action_type :integer          not null
#  target_id   :integer          not null
#  args        :text
#


class Action < ActiveRecord::Base

end
