
#= require_tree "./views"

Bixby.app.add_states

  "login":
    url:   "login"
    views: [ _bv.Login ]

    validate: ->
      # send to home if already logged in
      if Bixby.app.current_user
        @transition "inventory"
        return false
      return true

  "login_token":
    url:   "/login/token"
    views: [ _bv.LoginToken ]

  "forgot":
    url:   "forgot_password"
    views: [ _bv.ForgotPassword ]

  "reset_password":
    url: "users/password/edit"
    views: [ _bv.ResetPassword ]

  "profile":
    tab:   "user"
    url:   "profile"
    views: [ _bv.PageLayout, _bv.Profile ]

  "profile_edit":
    tab:   "user"
    url:   "profile/edit"
    views: [ _bv.PageLayout, _bv.ProfileEdit ]

  "profile_qr":
    tab:   "user"
    url:   "profile/enable_2fa"
    views: [ _bv.PageLayout, _bv.ProfileQR ]

    validate: ->
      @transition "profile"
      return @password_confirmed == true
