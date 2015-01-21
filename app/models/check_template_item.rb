# ## Schema Information
#
# Table name: `check_template_items`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `integer`          | `not null, primary key`
# **`check_template_id`**  | `integer`          | `not null`
# **`command_id`**         | `integer`          | `not null`
# **`args`**               | `text(65535)`      |
# **`created_at`**         | `datetime`         |
# **`updated_at`**         | `datetime`         |
# **`deleted_at`**         | `datetime`         |
#
# ### Indexes
#
# * `check_template_items_check_template_id_fk`:
#     * **`check_template_id`**
# * `check_template_items_command_id_fk`:
#     * **`command_id`**
#

require "rails_ext"

class CheckTemplateItem < ActiveRecord::Base
  belongs_to :check_template
  belongs_to :command

  serialize :args, JSONColumn.new

  acts_as_paranoid
end
