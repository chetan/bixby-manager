# == Schema Information
#
# Table name: user_permissions
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  permission_id :integer          not null
#  resource      :string(255)
#  resource_id   :integer
#


class UserPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :permission

  def name
    self.permission.name
  end
end
