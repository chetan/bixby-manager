# == Schema Information
#
# Table name: commands
#
#  id         :integer          not null, primary key
#  repo_id    :integer
#  name       :string(255)
#  desc       :string(255)
#  location   :string(255)
#  bundle     :string(255)
#  command    :string(255)
#  options    :text
#  updated_at :datetime
#  deleted_at :datetime
#


class Command < ActiveRecord::Base

  belongs_to :repo
  multi_tenant :via => :repo

  acts_as_paranoid

  serialize :options, JSONColumn.new

  def path
    File.join(repo.path, bundle, "bin", command)
  end

  # Convert CommandSpec to Command
  #
  # @param [CommandSpec] spec
  #
  # @return [Command]
  def self.from_command_spec(spec)
    repo = Repo.where(:name => spec.repo).first
    where(:repo_id => repo.id, :bundle => spec.bundle, :command => spec.command).first
  end

  # Convert this command to a CommandSpec
  #
  # @return [CommandSpec]
  def to_command_spec
    attrs = self.attributes
    attrs["repo"] = File.basename(repo.path) # 'vendor' or '0001_test' etc
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
