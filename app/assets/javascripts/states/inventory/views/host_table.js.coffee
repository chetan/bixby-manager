namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    bindings: [ "hosts" ]

    events:
      "focusin input.install": _.select_text

      "click button.add_host":(e) ->
        @$("#addHostModal").modal("show")
        @$("#addHostModal input.install").focus()

      "click button.show_inactive": (e) ->
        @transition("inv_search", {query: "is:inactive"})

    query_string: ->
      return "" if !@query
      return @query.replace(/tag:(.*?)\b/, "#$1")
