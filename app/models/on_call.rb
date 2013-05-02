# == Schema Information
#
# Table name: on_calls
#
#  id              :integer          not null, primary key
#  org_id          :integer          not null
#  name            :string(255)
#  rotation_period :integer
#  handoff_day     :integer
#  handoff_time    :time
#  current_user_id :integer
#  users           :string(255)
#  next_handoff    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class OnCall < ActiveRecord::Base

  belongs_to :org
  belongs_to :current_user, :class_name => User
  multi_tenant :via => :org

  serialize :users, CSVColumn.new

  # Get the next user in the rotation, if available
  #
  # @return [User]
  def next_user
    if self.users.blank?
      return nil
    end
    return User.find(self.users.first.to_i)
  end

end
