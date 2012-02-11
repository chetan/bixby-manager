
class Command < ActiveRecord::Base

  belongs_to :repo

  serialize :options, JSONColumn.new

  include Repository::Command

  def path
    File.join(repo.path, bundle, "bin", command)
  end

  def to_command_spec
    c = CommandSpec.new(self.attributes)
    c.repo = self.repo.name
    return c
  end

end
