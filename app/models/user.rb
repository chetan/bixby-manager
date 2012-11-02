
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
