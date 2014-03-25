# ## Schema Information
#
# Table name: `tenants`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`name`**         | `string(255)`      |
# **`password`**     | `string(255)`      |
# **`private_key`**  | `text`             |
#

class Tenant < ActiveRecord::Base

  has_many :orgs

  def test_password(pw)
    SCrypt::Password.new(password) == pw
  end

end
