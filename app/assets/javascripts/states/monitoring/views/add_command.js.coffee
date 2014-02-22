namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddCommand extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_command"

    events:
      "click #submit_check": (e) ->

        if $("h3#configure").length > 0
          # cheap hack to short-circuit double-bound event when opts view is displayed as well
          return

        # show options for selected commands/checks
        opts = []

        # filter the list of commands to include only the ones we have selected
        selected_commands = new Bixby.model.MonitoringCommandList()

        $("input.checkbox:checked").eachR @, (idx, el) ->
          opt = new Bixby.model.MonitoringCommandOpts({ id: el.value })
          opt.host = @host
          opts.push opt
          selected_commands.add @commands.get(el.value)

        if opts.length > 0
          @transition "mon_hosts_checks_new_opts", { host: @host, opts: opts, commands: selected_commands, hosts: @state.hosts }
