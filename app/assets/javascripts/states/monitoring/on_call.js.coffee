
_bv  = Bixby.view
_bvm = _bv.monitoring
_bm  = Bixby.model

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_oncalls_new"
    url:  "monitoring/on_calls/new"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddOnCall ]
    models:     { users: _bm.UserList }
)

