
#= require_tree "./views"

help =
  on_calls: "On call schedules are a way to rotate the responsibility for responding to alert events. Only the users who are on call at any given time will receive a page.\n\nFor example, a schedule which rotates every 7 days on Monday at 12pm allows for users to be on call for a week at a time."

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  # On calls home
  "mon_oncalls":
    url:    "monitoring/on_calls"
    help:   help.on_calls

    views:  [ _bvm.OnCallIndex ]
    models:
      on_calls: _bm.OnCallList
      users:   _bm.UserList

  "mon_oncalls_new":
    url:  "monitoring/on_calls/new"
    help:   help.on_calls

    views:  _bvm.AddOnCall
    models: { users: _bm.UserList }
