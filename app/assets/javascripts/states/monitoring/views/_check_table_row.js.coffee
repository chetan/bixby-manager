namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTableRow extends Stark.Partial

    template: "monitoring/_check_table_row"

    events:
      "click #delete_check": (e) ->
        c = @create_partial Bixby.view.Confirm,
          message: "Are you sure you want to delete '#{@check.name}'?",
          hidden_cb: (confirmed) =>
            if confirmed
              @check.destroy
                success: =>
                  @host.update_check_config()
                  @state.redraw()
        c.render()

      "click a.edit": ->
        check_editor = @partial(exports.CheckEditor, { check: @check, host: @host, hosts: @hosts })
        check_editor.show() # TODO load options here
