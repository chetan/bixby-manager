# ## Schema Information
#
# Table name: `orgs`
#
# ### Columns
#
# Name             | Type               | Attributes
# ---------------- | ------------------ | ---------------------------
# **`id`**         | `integer`          | `not null, primary key`
# **`tenant_id`**  | `integer`          |
# **`name`**       | `string(255)`      |
#
# ### Indexes
#
# * `fk_orgs_tenants1`:
#     * **`tenant_id`**
#

class Org < ActiveRecord::Base

  belongs_to :tenant
  has_many :repos
  has_many :users
  has_many :hosts

  multi_tenant

end
