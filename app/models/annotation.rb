# ## Schema Information
#
# Table name: `annotations`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`org_id`**      | `integer`          | `not null`
# **`host_id`**     | `integer`          |
# **`name`**        | `string(255)`      | `not null`
# **`detail`**      | `text(65535)`      |
# **`created_at`**  | `datetime`         |
#
# ### Indexes
#
# * `fk_annotations_hosts1_idx`:
#     * **`host_id`**
#

class Annotation < ActiveRecord::Base

  belongs_to :host
  acts_as_taggable # adds :tags accessor

  multi_tenant :via => :host

end
