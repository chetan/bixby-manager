# ## Schema Information
#
# Table name: `user_permissions`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`user_id`**        | `integer`          | `not null`
# **`permission_id`**  | `integer`          | `not null`
# **`resource`**       | `string(255)`      |
# **`resource_id`**    | `integer`          |
#
# ### Indexes
#
# * `user_permissions_permission_id_fk`:
#     * **`permission_id`**
# * `user_permissions_user_id_fk`:
#     * **`user_id`**
#

class UserPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :permission

  def name
    self.permission.name
  end
end
