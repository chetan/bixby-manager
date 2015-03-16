# ## Schema Information
#
# Table name: `tokens`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`org_id`**        | `integer`          |
# **`user_id`**       | `integer`          |
# **`token`**         | `string(16)`       |
# **`purpose`**       | `string(255)`      |
# **`created_at`**    | `datetime`         |
# **`last_used_at`**  | `datetime`         |
# **`deleted_at`**    | `datetime`         |
#
# ### Indexes
#
# * `fk_rails_25f1ffe905`:
#     * **`org_id`**
# * `fk_rails_6096b147cb`:
#     * **`user_id`**
#

class Token < ActiveRecord::Base

  belongs_to :org
  belongs_to :user

  def self.create(user, purpose=nil)
    t = Token.new

    t.org_id  = user.org_id
    t.user_id = user.id
    t.token   = SecureRandom.hex(8) # 16 chars
    t.purpose = purpose || "default"
    t.save!

    t
  end

end
