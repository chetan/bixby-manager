
#= require_tree "./views"

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  "mon_oncalls_new":
    url:  "monitoring/on_calls/new"
    tab:  "monitoring"

    views:  _bvm.AddOnCall
    models: { users: _bm.UserList }
