
#= require "./monitoring"

_bv  = Bixby.view
_bvm = _bv.monitoring
_bm  = Bixby.model

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  "mon_check_template_new":
    url:  "monitoring/check_templates/new"

    views:  [ _bvm.NewCheckTemplate ]
    models: { commands: _bm.MonitoringCommandList, tags: _bm.HostTagList }
