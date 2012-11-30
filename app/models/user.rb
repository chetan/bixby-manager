# == Schema Information
#
# Table name: users
#
#  id       :integer          not null, primary key
#  org_id   :integer          not null
#  username :string(255)      not null
#  password :string(89)
#  name     :string(255)
#  email    :string(255)
#  phone    :string(255)
#


class User < ActiveRecord::Base

  belongs_to :org

  # Test the given password against the one on file
  #
  # @param [String] pw      plaintext password (unhashed)
  #
  # @return [Boolean] Returns true if passwords match
  def test_password(pw)
    SCrypt::Password.new(self.password) == pw
  end

end
