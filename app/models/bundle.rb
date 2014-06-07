
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

  def fullpath
    File.join(repo.path, self.path)
  end

end
