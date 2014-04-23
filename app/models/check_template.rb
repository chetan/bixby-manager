# ## Schema Information
#
# Table name: `check_templates`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`org_id`**      | `integer`          |
# **`name`**        | `string(255)`      | `not null`
# **`mode`**        | `integer`          | `not null`
# **`tags`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#
# ### Indexes
#
# * `check_templates_org_id_fk`:
#     * **`org_id`**
#

class CheckTemplate < ActiveRecord::Base

  has_many :items, :class_name => "CheckTemplateItem", :dependent => :destroy
  belongs_to :org
  multi_tenant :via => :org

  acts_as_paranoid

  module Mode
    ANY    = 1 # any tag matches
    ALL    = 2 # all tags match
    EXCEPT = 3 # all or no tags, except the following (don't apply if any of the tags are present)
  end if not const_defined? :Mode
  Bixby::Util.create_const_map(Mode)

  # Ensure mode is set to the correct constant val
  def mode=(val)
    if val.blank? or val.kind_of? Fixnum then
      write_attribute(:mode, val)
    else
      write_attribute(:mode, Mode[val])
    end
  end

end
