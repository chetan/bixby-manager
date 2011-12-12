
class Command < ActiveRecord::Base

  belongs_to :repo

  def path
    File.join(repo.path, bundle, command)
  end

end
