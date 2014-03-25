# ## Schema Information
#
# Table name: `host_groups`
#
# ### Columns
#
# Name             | Type               | Attributes
# ---------------- | ------------------ | ---------------------------
# **`id`**         | `integer`          | `not null, primary key`
# **`org_id`**     | `integer`          | `not null`
# **`parent_id`**  | `integer`          |
# **`name`**       | `string(255)`      | `not null`
#
# ### Indexes
#
# * `fk_host_groups_host_groups1`:
#     * **`parent_id`**
# * `fk_host_groups_orgs1`:
#     * **`org_id`**
#

class HostGroup < ActiveRecord::Base

  include ActsAsTree
  acts_as_tree :order => "name"

end
