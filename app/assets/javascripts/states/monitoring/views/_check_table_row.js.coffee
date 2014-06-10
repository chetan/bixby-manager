namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTableRow extends Stark.Partial

    template: "monitoring/_check_table_row"

    events:
      "click #delete_check": (e) ->
        v = @
        @check.destroy success: (model, response) ->
          console.log this
          v.parent.redraw()