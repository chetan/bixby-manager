
class OnCall < ActiveRecord::Base

  belongs_to :org
  has_one :current_user, :class_name => User, :foreign_key => :id

  serialize :users, CSVColumn.new

  # Get the OnCall rotation for the given Org
  #
  # @param [Org] org
  # @return [OnCall]
  def self.for_org(org)
    return self.first(:conditions => {:org_id => org.id})
  end

  # Get the next user in the rotation, if available
  #
  # @return [User]
  def next_user
    if self.users.blank?
      return nil
    end
    return User.find(self.users.first.to_i)
  end

end
