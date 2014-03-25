# ## Schema Information
#
# Table name: `permissions`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`name`**         | `string(255)`      | `not null`
# **`description`**  | `string(255)`      |
#

class Permission < ActiveRecord::Base

end
