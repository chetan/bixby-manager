
class UserSession < Authlogic::Session::Base
  login_field :email
  logout_on_timeout true
end
