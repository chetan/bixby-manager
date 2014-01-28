# == Schema Information
#
# Table name: role_permissions
#
#  id            :integer          not null, primary key
#  role_id       :integer          not null
#  permission_id :integer          not null
#  resource      :string(255)
#  resource_id   :integer
#


class RolePermission < ActiveRecord::Base
  belongs_to :role
  belongs_to :permission

  def name
    self.permission.name
  end
end
