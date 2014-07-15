namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckGroup extends Stark.View

    el: "div.monitoring_content"
    template: "monitoring/check_group"

    events:
      "click button.return_host": (e) ->
        @transition "mon_view_host", {host: @host}

      "click #delete_check": (e) ->
        c = @create_partial Bixby.view.Confirm,
          message: "Are you sure you want to delete '#{@check.name}'?",
          hidden_cb: (confirmed) =>
            if confirmed
              @check.destroy()
              @transition "mon_view_host", {host: @host}
        c.render()
      "click a.edit": ->
        check_editor = @partial(exports.CheckEditor, { check: @check, host: @host, hosts: @hosts })
        check_editor.show() # TODO load options here

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)
