
#= require_tree "./views"

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  "monitoring_overview":
    url:    "monitoring"

    views:  [ _bvm.MonitoringOverview ]
    models:
      hosts:   _bm.HostList
      metrics: _bm.SummaryMetricList

  # Host summary
  "mon_view_host":
    url:  "monitoring/hosts/:host_id"

    views:      [ _bvm.HostSummary ]
    models:     { host: _bm.Host, metrics: _bm.HostSummaryMetricList }

  # All host metrics
  "mon_view_host_all":
    url:  "monitoring/hosts/:host_id/metrics"

    views:      [ _bvm.CheckList ]
    models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }

  # Check group
  "mon_hosts_check":
    url:  "monitoring/hosts/:host_id/checks/:check_id"

    views:      [ _bvm.CheckGroup ]
    models:     { host: _bm.Host, check: _bm.Check, metrics: _bm.MetricList, hosts: _bm.HostList }

  # Metric detail
  "mon_hosts_metric":
    url:  "monitoring/hosts/:host_id/metrics/:metric_id"

    views:      [ _bvm.MetricDetail ]
    models:     { host: _bm.Host, check: _bm.Check, metric: _bm.Metric }

  # Add check
  "mon_hosts_checks_new":
    url:  "monitoring/hosts/:host_id/checks/new"

    views:      [ _bvm.AddCommand ]
    models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }

    activate: ->
      # preload hosts in the background
      if !@hosts?
        @hosts = new _bm.HostList
        Backbone.multi_fetch(@hosts)

  # Check table - edit/delete
  "mon_hosts_check_table":
    url:  "monitoring/hosts/:host_id/checks"

    views:  B.CheckTable
    models:
      host:     _bm.Host
      checks:   _bm.CheckList
      hosts:    _bm.HostList


  # Configure check options
  "mon_hosts_checks_new_opts":
    class extends Stark.State
      url:  "#configure"

      views:      [ _bvm.AddCommand, _bvm.AddCommandOpts ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList, opts: _bm.MonitoringCommandOpts }

      load_data: (data) ->
        needed = super(data)

        # only load opts for checks which have/need them
        opts_needed = []
        _.eachR @, @opts, (opt) ->
          cmd = @commands.get(opt.id)
          cmd.checked = true
          if cmd.has_enum_options()
            opts_needed.push opt
          else
            opt.set(cmd.attributes, {silent: true})

        needed = _.union(needed, opts_needed)
        @spinner = new _bv.Spinner($("div.command_opts").height(30).css({ padding: "20px" }))
        return needed

      activate: ->
        @spinner.stop()
        $("a#submit_check").html("Add Check(s)")

  # New trigger
  "mon_hosts_triggers_new":
    class extends Stark.State
      url: "monitoring/hosts/:host_id/triggers/new"

      create_url: ->
        s = super()
        if @for_check? and @for_metric?
          s += "?for_check=#{@for_check.id}&for_metric=#{@for_metric.id}"
        s

      views:      [ _bvm.AddTrigger ]
      models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }

      activate: ->
        # preload some extra data for next step
        @users = new _bm.UserList
        @on_calls = new _bm.OnCallList
        needed = [@users, @on_calls]
        Backbone.multi_fetch(needed)

  # Add trigger action
  "mon_hosts_actions_new":
    url:  "monitoring/hosts/:host_id/triggers/:trigger_id/actions/new"

    views:      [ _bvm.AddTriggerAction ]
    models:     { host: _bm.Host, trigger: _bm.Trigger, on_calls: _bm.OnCallList, users: _bm.UserList }
