# ## Schema Information
#
# Table name: `bundles`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`repo_id`**     | `integer`          |
# **`path`**        | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`desc`**        | `text(65535)`      |
# **`version`**     | `string(255)`      |
# **`digest`**      | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#
# ### Indexes
#
# * `bundles_repo_id_fk`:
#     * **`repo_id`**
#

class Bundle < ActiveRecord::Base

  belongs_to :repo
  has_many :commands

  acts_as_paranoid
  multi_tenant :via => :repo

  # Shortcut accessor for this Bundle's Org
  #
  # @return [Org]
  def org
    self.repo.org
  end

  def relative_path
    self.path
  end

  def fullpath
    File.join(repo.path, self.path)
  end

  def to_command_spec
    attrs = self.attributes.slice(:name, :desc)
    attrs["repo"] = repo.relative_path # 'vendor' or '0001_test' etc
    attrs["bundle"] = self.relative_path
    return Bixby::CommandSpec.new(attrs)
  end

end
