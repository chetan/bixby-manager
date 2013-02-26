
#= require_tree "./views"

_bv = Bixby.view
_bvm = _bv.monitoring
_bm = Bixby.model

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_view_host"
    url:  "monitoring/hosts/:host_id"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.MetricList ]
    models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }
)

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_hosts_resources_metric"
    url:  "monitoring/hosts/:host_id/metrics/:metric_id"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.MetricDetail ]
    models:     { host: _bm.Host, check: _bm.Check, metric: _bm.Metric }
)

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_hosts_resources_new"
    url:  "monitoring/hosts/:host_id/checks/new"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddCommand ]
    models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }
)

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_hosts_resources_new_opts"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddCommand, _bvm.AddCommandOpts ]
    models:     { host: _bm.Host, commands: _bm.MonitoringCommandList, opts: _bm.MonitoringCommandOpts }

    load_data: (data) ->
      needed = super(data)
      @log "opts: ", @opts
      needed = _.union(needed, @opts)
      @spinner = new _bv.Spinner($("div.command_opts"))
      return needed

    activate: ->
      @spinner.stop()

)

