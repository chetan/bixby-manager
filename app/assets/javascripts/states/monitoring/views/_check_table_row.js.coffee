namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTableRow extends Stark.Partial

    template: "monitoring/_check_table_row"

    events:
      "click #delete_check": (e) ->
        v = @
        @check.destroy success: (model, response) ->
          v.parent.redraw()

      "click a.edit": ->
        check_editor = @partial(exports.CheckEditor, { check: @check, host: @host, hosts: @hosts })
        check_editor.show() # TODO load options here
