namespace "Bixby.view.inventory", (exports, top) ->

  class exports.GettingStarted extends Stark.View
    el: "div.inventory_content"
    template: "inventory/getting_started"

    events: {
      "focusin input.install": (e) ->
        # TODO extract common method
        # reused in host_table view
        $(e.target).mouseup (e) ->
          setTimeoutR 0, ->
            e.target.select()
          $(this).unbind()

        setTimeoutR 0, ->
          e.target.select()
    }
