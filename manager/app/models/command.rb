
class Command < ActiveRecord::Base

  belongs_to :repo

  serialize :options, JSONColumn.new

  include Repository::Command

  def path
    File.join(repo.path, bundle, "bin", command)
  end

end
