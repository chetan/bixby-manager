# ## Schema Information
#
# Table name: `roles`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`tenant_id`**    | `integer`          |
# **`name`**         | `string(255)`      | `not null`
# **`description`**  | `string(255)`      |
#
# ### Indexes
#
# * `roles_tenant_id_fk`:
#     * **`tenant_id`**
#

class Role < ActiveRecord::Base

  has_many :role_permissions, -> { includes :permission }
  # has_many :permissions, :through => :role_permissions

  has_and_belongs_to_many :users, :join_table => :users_roles

  def add_permission(permission, resource=nil)
    self.save! if self.id.blank?
    rp = RolePermission.new
    rp.role_id = self.id
    rp.permission_id = permission.kind_of?(Permission) ? permission.id : permission
    if resource then
      rp.resource = resource.class.name
      rp.resource_id = resource.id
    end
    rp.save
    self.role_permissions << rp
  end

end
