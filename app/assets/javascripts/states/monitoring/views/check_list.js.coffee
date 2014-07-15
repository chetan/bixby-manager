namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_list"

    links:
      ".edit_checks": [ "mon_hosts_check_table", (el) -> return { host: @host, checks: @checks } ]
      ".add_check":   [ "mon_hosts_checks_new", (el) -> return { host: @host } ]
      ".add_trigger": [ "mon_hosts_triggers_new", (el) ->
        return { host: @host, metrics: @metrics, checks: @checks }
        ]

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)

      # only display the top controls if the bottom ones are off page
      if ! _.isScrolledIntoView(@$("p.bottom"))
        @$("p.top").removeClass("hidden").show()
