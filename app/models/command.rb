# == Schema Information
#
# Table name: commands
#
#  id         :integer          not null, primary key
#  repo_id    :integer
#  name       :string(255)
#  bundle     :string(255)
#  command    :string(255)
#  options    :text
#  updated_at :datetime
#


class Command < ActiveRecord::Base

  belongs_to :repo

  multi_tenant :via => :repo

  serialize :options, JSONColumn.new

  def path
    File.join(repo.path, bundle, "bin", command)
  end

  def to_command_spec
    attrs = self.attributes
    attrs["repo"] = repo.name
    return Bixby::CommandSpec.new(attrs)
  end

  def self.for_user(user)
    for_repos(Repo.for_user(user))
  end

  def self.for_repos(repos)
    where(:repo_id => repos.map{|r| r.id})
  end
end
