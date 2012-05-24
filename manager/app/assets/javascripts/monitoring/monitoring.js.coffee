
jQuery ->

  _bv = Bixby.view
  _vn = _bv.monitoring
  _bm = Bixby.model
  Bixby.app.add_state(
    class MonViewHostState extends Stark.State
      name: "mon_view_host" #  canonical name used for state transitions
                            #  e.g., it is referred to in events hash of other states

      url:  "monitoring/hosts/:host_id" #  match() pattern [optional]

      views:      [ _bv.PageLayout, _vn.Layout, _vn.MetricList ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }

      events: {
        mon_hosts_resources_new: { models: [ _bm.Host ] }
        mon_hosts_resources_metric: { models: [ _bm.Host, _bm.Metric ]}
      }

      create_url: ->
        @url.replace /:host_id/, @host.id

      activate: ->
        @app.trigger("nav:select_tab", "monitoring")
  )

  Bixby.app.add_state(
    class extends Stark.State

      name: "mon_hosts_resources_metric"
      url:  "monitoring/hosts/:host_id/metrics/:metric_id"

      create_url: ->
        @url.replace(/:host_id/, @host.id).replace(/:metric_id/, @metric.id)


      views:      [ _bv.PageLayout, _vn.Layout, _vn.MetricDetail ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, check: _bm.Check, metric: _bm.Metric }
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new"
      url:  "monitoring/hosts/:host_id/checks/new"

      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }

      create_url: ->
        @url.replace /:host_id/, @host.id

  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new_opts"
      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand, _vn.AddCommandOpts ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }

      load_data: (data) ->
        needed = super(data)
        @log "commands: ", @commands
        needed = _.union(needed, @commands)
        @spinner = new _bv.Spinner($("div.command_opts"))
        return needed

      activate: ->
        @spinner.stop()

  )

