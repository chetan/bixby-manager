
#= require "./monitoring"

_bv  = Bixby.view
_bvm = _bv.monitoring
_bm  = Bixby.model

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_check_template_new"
    url:  "monitoring/check_templates/new"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.NewCheckTemplate ]
    models:     { commands: _bm.MonitoringCommandList }
)

