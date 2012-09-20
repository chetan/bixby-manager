namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddCommand extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_command"
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
          @transition "mon_hosts_resources_new_opts", { host: @host, opts: opts, commands: @commands }
    }
