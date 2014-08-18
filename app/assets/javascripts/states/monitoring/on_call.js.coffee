
#= require_tree "./views"

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  # On calls home
  "mon_oncalls":
    url:    "monitoring/on_calls"

    views:  [ _bvm.OnCallIndex ]
    models:
      on_calls: _bm.OnCallList
      users:   _bm.UserList

  "mon_oncalls_new":
    url:  "monitoring/on_calls/new"

    views:  _bvm.AddOnCall
    models: { users: _bm.UserList }
