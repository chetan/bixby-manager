
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Layout extends Stark.View
    el: "#content"
    template: "monitoring/layout"


  class exports.MetricList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/resource_list"
    events: {
      "click .add_resource_link": (e) ->
        @transition "mon_hosts_resources_new", { host: @host }
      "click div.metric a.metric": (e) ->
        check = @checks.get $(e.target).attr("check_id")
        metric = @metrics.get $(e.target).attr("metric_id")
        @transition "mon_hosts_resources_metric", { host: @host, check: check, metric: metric }
    }

    render: ->
      super()

      # render graphs into placeholder divs
      @metrics.each (metric) ->
        s = ".check[check_id=" + metric.get("check_id") + "] .metric[metric_id='" + metric.id + "']"
        Bixby.monitoring.render_metric(s, metric)

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"
    render: ->
      super()
      s = ".metric[metric_id='" + @metric.id + "']"
      Bixby.monitoring.render_metric(s, @metric)


  class exports.AddCommand extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/command_add"
    events: {
      "click #submit_check": (e) ->
        # show options for selected commands/checks
        opts = []
        host = @host
        $("input.checkbox:checked").each (idx, el) ->
          opt = new Bixby.model.MonitoringCommandOpts({ id: el.value })
          opt.host = host
          opts.push opt

        if opts.length > 0
          @transition "mon_hosts_resources_new_opts", { host: @host, commands: opts }
    }


  class exports.AddCommandOpts extends Stark.View
    el: "div.command_opts"
    template: "monitoring/command_add_opts"
    events: ->
      view = @
      $("#submit_check").on "click", null, (e) ->
        # create the commands
        checks = []
        _.each view.commands, (cmd) ->
          check = new Bixby.model.Check()
          check.host = cmd.host
          check.set { command_id: cmd.id, host_id: cmd.host.id }

          args = {}
          # gather values
          _.each cmd.get("options"), (opt_hash, opt) ->
            args[opt] = $("##{opt}").val()

          check.set({ args: args })
          checks.push check

        Backbone.multi_save checks, (err, results) ->
          view.transition "mon_view_host", { host: view.host }

      {} # return empty event hash
