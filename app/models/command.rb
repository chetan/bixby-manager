
class Command < ActiveRecord::Base

  belongs_to :repo

  serialize :options, JSONColumn.new

  def path
    File.join(repo.path, bundle, "bin", command)
  end

  def to_command_spec
    c = Bixby::CommandSpec.new(self.attributes)
    c.repo = self.repo.name
    return c
  end

end
