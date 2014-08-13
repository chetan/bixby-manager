# ## Schema Information
#
# Table name: `sessions`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`session_id`**  | `string(255)`      | `not null`
# **`data`**        | `text`             |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_sessions_on_session_id`:
#     * **`session_id`**
# * `index_sessions_on_updated_at`:
#     * **`updated_at`**
#

class Session < ActiveRecord::SessionStore::Session
  def self.sweep!(time = 35.days)
    raise "time must be of type Fixnum" if not time.kind_of? Fixnum
    where("updated_at < ?", time.ago).delete_all
  end
end
