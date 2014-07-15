namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckGroup extends Stark.View

    el: "div.monitoring_content"
    template: "monitoring/check_group"

    events:
      "click button.return_host": (e) ->
        @transition "mon_view_host", {host: @host}
      "click #delete_check": (e) ->
        @check.destroy success: (model, response) =>
          @transition "mon_view_host", {host: @host}

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)
