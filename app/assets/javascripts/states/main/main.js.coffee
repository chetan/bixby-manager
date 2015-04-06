
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

  "login_fail":
    url:   "/login/fail"
    views: [ _bv.Login ]

  "login_token":
    url:   "/login/verify_token"
    views: [ _bv.LoginToken ]

  "forgot":
    url:   "forgot_password"
    views: [ _bv.ForgotPassword ]

  "reset_password":
    url: "reset_password"
    views: [ _bv.ResetPassword ]

  "accept_invite":
    url: "accept_invite"
    views: [ _bv.AcceptInvite ]

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

  "team":
    tab:    "user"
    url:    "team"
    views:  [ _bv.PageLayout, _bv.Team ]
    models: { users: _bm.UserList }

  "team_user_view":
    tab:    "user"
    url:    "team/users/:user_id"
    views:  [ _bv.PageLayout, _bv.TeamUser ]
    models: { user: _bm.User }

  "team_user_edit":
    tab:    "user"
    url:    "team/users/:user_id/edit"
    views:  [ _bv.PageLayout, _bv.TeamUserEdit ]
    models: { user: _bm.User }
