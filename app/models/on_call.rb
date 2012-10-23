
class OnCall < ActiveRecord::Base

  has_one :current_user, :class_name => User

  serialize :users, CSVColumn.new

  def next_user
    if self.users.blank?
      return nil
    end
    return User.find(self.users.first.to_i)
  end

end
