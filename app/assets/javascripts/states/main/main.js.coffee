
#= require_tree "./views"

_bv = Bixby.view

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

  "profile":
    url:   "profile"
    views: [ _bv.PageLayout, _bv.Profile ]

  "profile_edit":
    url:   "profile/edit"
    views: [ _bv.PageLayout, _bv.ProfileEdit ]
