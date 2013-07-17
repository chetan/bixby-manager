
#= require_tree "./views"

_bv = Bixby.view
_bvm = _bv.monitoring
_bm = Bixby.model

Bixby.app.add_state(
  class extends Stark.State
    name:   "monitoring"
    url:    "monitoring"
    tab:    "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.Monitoring ]
    models:     { oncalls: _bm.OnCallList, users: _bm.UserList }

)

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
    url:  "#configure"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddCommand, _bvm.AddCommandOpts ]
    models:     { host: _bm.Host, commands: _bm.MonitoringCommandList, opts: _bm.MonitoringCommandOpts }

    load_data: (data) ->
      needed = super(data)

      # filter the list of commands to include only the ones we have selected
      all_commands = new _bm.MonitoringCommandList( _.union([], @commands.models) )
      @commands.reset()

      # only load opts for checks which have/need them
      opts_needed = []
      _.eachR @, @opts, (opt) ->
        cmd = all_commands.get(opt.id)
        cmd.checked = true
        @commands.add(cmd)
        if ! _.isEmpty(cmd.get("options"))
          opts_needed.push opt
        else
          opt.set(cmd.attributes, {silent: true})


      needed = _.union(needed, opts_needed)
      @spinner = new _bv.Spinner($("div.command_opts").height(30).css({ padding: "20px" }))
      return needed

    activate: ->
      @spinner.stop()
      $("a#submit_check").html("Add Check(s)")

)

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_hosts_triggers_new"
    url:  "monitoring/hosts/:host_id/triggers/new"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddTrigger ]
    models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }

    activate: ->
      # preload some extra data for next step
      @users = new _bm.UserList
      @oncalls = new _bm.OnCallList
      needed = [@users, @oncalls]
      Backbone.multi_fetch(needed)
)

Bixby.app.add_state(
  class extends Stark.State

    name: "mon_hosts_actions_new"
    url:  "monitoring/hosts/:host_id/triggers/:trigger_id/actions/new"
    tab:  "monitoring"

    views:      [ _bv.PageLayout, _bvm.Layout, _bvm.AddTriggerAction ]
    models:     { host: _bm.Host, trigger: _bm.Trigger, oncalls: _bm.OnCallList, users: _bm.UserList }
)

