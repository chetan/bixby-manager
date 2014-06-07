# ## Schema Information
#
# Table name: `commands`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`repo_id`**     | `integer`          |
# **`name`**        | `string(255)`      |
# **`desc`**        | `string(255)`      |
# **`location`**    | `string(255)`      |
# **`bundle`**      | `string(255)`      |
# **`command`**     | `string(255)`      |
# **`options`**     | `text`             |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#
# ### Indexes
#
# * `fk_commands_repos1`:
#     * **`repo_id`**
#

class Command < ActiveRecord::Base

  belongs_to :repo
  belongs_to :bundle
  multi_tenant :via => :repo

  acts_as_paranoid

  serialize :options, JSONColumn.new

  def path
    File.join(bundle.fullpath, "bin", command)
  end

  # Convert CommandSpec to Command
  #
  # @param [CommandSpec] spec
  #
  # @return [Command]
  def self.from_command_spec(spec)
    repo = Repo.where(:name => spec.repo).first
    bundle = Bundle.where(:repo_id => repo.id, :path => spec.bundle).first
    where(:repo_id => repo.id, :bundle_id => bundle.id, :command => spec.command).first
  end

  # Convert this command to a CommandSpec
  #
  # @return [CommandSpec]
  def to_command_spec
    attrs = self.attributes
    attrs["repo"] = File.basename(repo.path) # 'vendor' or '0001_test' etc
    attrs["bundle"] = bundle.path
    return Bixby::CommandSpec.new(attrs)
  end

  def self.for_user(user)
    for_repos(Repo.for_user(user))
  end

  def self.for_repos(repos)
    where(:repo_id => repos.map{|r| r.id})
  end

  def self.for_monitoring
    where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")
  end
end
