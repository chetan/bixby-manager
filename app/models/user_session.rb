
class UserSession < Authlogic::Session::Base
  find_by_login_method :find_by_username_or_email
  login_field :login
  logout_on_timeout true
end
