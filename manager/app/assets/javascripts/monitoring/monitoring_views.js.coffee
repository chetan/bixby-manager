
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Layout extends Stark.View
    el: "#content"
    template: "monitoring/layout"


  class exports.ResourceList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/resource_list"
    events: {
      "click .add_resource_link": (e) ->
        @transition "mon_hosts_resources_new", { host: @host }
    }

    render: ->
      super()

      # display graphs
      @resources.each (res) ->
        metrics = res.get("metrics");
        _.each metrics, (val, key) ->
          s = ".resource[resource_id=" + res.id + "] .metric[metric='" + key + "']"
          el = $(s + " .graph")[0]

          vals = _.map val.vals, (v) ->
            [ new Date(v.x * 1000), v.y ]

          g = new Dygraph(
            el, vals,
            {
              labels: [ "Date/Time", "val" ]
              strokeWidth: 2
            }
            );

          $(s + " .footer").text(sprintf("Last Value: %0.2f", val.vals[val.vals.length-1].y));

    render_with_rickshaw: ->
      render()

      # display graphs
      @resources.each (res) ->
        metrics = res.get("metrics");
        _.each metrics, (val, key) ->
          s = ".resource[resource_id=" + res.id + "] .metric[metric='" + key + "']"
          el = $(s + " .graph")[0]

          graph = new Rickshaw.Graph( {
            element: el,
            width: 300,
            height: 100,
            renderer: 'line',
            series: [{
              # name: "foo",
              color: 'steelblue',
              data: val.vals
            }]
          } );
          x_axis = new Rickshaw.Graph.Axis.Time({
            graph: graph,
            # element: $(s + ' .x_axis')[0]
          });
          y_axis = new Rickshaw.Graph.Axis.Y({
            graph: graph,
            orientation: 'left',
            # tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
            element: $(s + ' .y_axis')[0],
          });
          hoverDetail = new Rickshaw.Graph.HoverDetail({
            graph: graph
          });
          graph.render();
          $(s + " .footer").text(sprintf("Last Value: %0.2f", val.vals[val.vals.length-1].y));


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
