
#= require_tree "./views"

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "runbooks":
    url:    "runbooks"
    help:   "This page allows you to easily run a script on one or more of your servers.\n\nIn order to see your own custom scripts in the list below, you can attach a Git or Subversion repository by going to [Runbooks > Manage Repositories](/repository)."

    views:  B.RunCommand
    models: [ B.m.HostList, B.m.CommandList ]

    validate: ->
      if !(!@current_user.get("otp_required_for_login") || @password_confirmed == true)
        @transition "inventory"
        return false
      return true
