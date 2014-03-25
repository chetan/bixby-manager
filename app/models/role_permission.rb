# ## Schema Information
#
# Table name: `role_permissions`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`role_id`**        | `integer`          | `not null`
# **`permission_id`**  | `integer`          | `not null`
# **`resource`**       | `string(255)`      |
# **`resource_id`**    | `integer`          |
#
# ### Indexes
#
# * `role_permissions_permission_id_fk`:
#     * **`permission_id`**
# * `role_permissions_role_id_fk`:
#     * **`role_id`**
#

class RolePermission < ActiveRecord::Base
  belongs_to :role
  belongs_to :permission

  def name
    self.permission.name
  end
end
