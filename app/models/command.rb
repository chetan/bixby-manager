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
# **`bundle_id`**   | `integer`          | `not null`
# **`name`**        | `string(255)`      |
# **`desc`**        | `string(255)`      |
# **`location`**    | `string(255)`      |
# **`command`**     | `string(255)`      |
# **`options`**     | `text`             |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#
# ### Indexes
#
# * `commands_bundle_id_fk`:
#     * **`bundle_id`**
# * `fk_commands_repos1`:
#     * **`repo_id`**
#

require "rails_ext"

class Command < ActiveRecord::Base

  paginates_per      100
  max_paginates_per  500

  belongs_to :repo, -> { includes :org }
  belongs_to :bundle
  has_many :metric_infos

  multi_tenant :via => :repo

  acts_as_paranoid

  serialize :options, JSONColumn.new

  def path
    File.join(bundle.fullpath, "bin", command)
  end

  def display_name
    name || script
  end

  def script
    File.join(bundle.path, "bin", command)
  end

  # Convert CommandSpec to Command
  #
  # @param [CommandSpec] spec
  #
  # @return [Command]
  def self.from_command_spec(spec)
    repo = spec.repo =~ /^(\d+)_(.*)$/ ? $2 : spec.repo
    repo = Repo.where(:name => repo).first
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
    if repos.respond_to?(:map) then
      repos = repos.map{|r| r.id}
    end
    where(:repo_id => repos).includes(:bundle, :repo)
  end

  def self.for_monitoring(user)
    for_user(user).where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")
  end
end
