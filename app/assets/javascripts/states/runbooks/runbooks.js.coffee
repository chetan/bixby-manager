
#= require_tree "./views"

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "runbooks":
    url:    "runbooks"

    views:      B.RunCommand
    models:     { hosts: _bm.HostList, commands: _bm.CommandList }
