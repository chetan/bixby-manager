
#= require_tree "./views"

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "runbooks":
    url:    "runbooks"

    views:  B.RunCommand
    models: [ B.m.HostList, B.m.CommandList ]

    validate: ->
      return !@current_user.get("otp_required_for_login") || @password_confirmed == true
