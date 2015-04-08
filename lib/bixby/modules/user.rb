
require 'securerandom'

module Bixby
class User < API

  # used for random pw generation
  CHARS         = ((('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a)  - "io01lO".split(//u)).shuffle
  SPECIAL_CHARS = "%&/()[]!\"§$,.-;:_#'+*?".split(//u)

  # Create a new tenant
  #
  # @param [String] name
  # @param [String] password
  #
  # @return [Tenant] newly created tenant object
  def create_tenant(name, password)

    t = Tenant.where(:name => name)
    if not t.blank? then
      raise API::Error, "duplicate tenant name", caller
    end

    t = Tenant.new
    t.name = name
    t.password = SCrypt::Password.create(password).to_s
    t.private_key = OpenSSL::PKey::RSA.generate(2048).to_s
    t.save!

    o = Org.new
    o.tenant = t
    o.name = "default"
    o.save!

    return t
  end

  # Create a new user
  #
  # @param [Tenant] tenant            Tenant user belongs to
  # @param [String] name              User's name
  # @param [String] username          Username (for logging in)
  # @param [String] password          Password
  # @param [String] email             Email address
  # @param [String] phone             (default: nil)
  # @param [Org] org                  (default: nil)
  def create_user(tenant, name, username, password, email, phone=nil, org=nil)
    t = get_model(tenant, Tenant)
    if t.blank? then
      raise API::Error, "invalid tenant", caller
    end

    u = ::User.where(:username => username)
    if not u.blank? then
      raise API::Error, "duplicate username", caller
    end

    u = ::User.new
    u.org_id = (org || Org.where(:tenant_id => t.id, :name => 'default').first).id
    u.name = name
    u.username = username
    u.email = email
    u.password = password
    u.password_confirmation = password
    u.phone = phone
    u.skip_confirmation!
    u.save!

    Token.create(u, "default")

   return u
  end

  # Generate a random password, 16 chars in length
  def random_password
    s = []
    13.times { s << CHARS[SecureRandom.random_number(CHARS.length)] }
    3.times { s << SPECIAL_CHARS[SecureRandom.random_number(SPECIAL_CHARS.length)] }
    s.shuffle.join('')
  end

end # User
end # Bixby
