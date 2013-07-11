namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    bindings: [ "hosts" ]

    events:
      "focusin input.install": _.select_text

      "click button.add_host":(e) ->
        e.preventDefault()
        @$("#addHostModal").modal("show")
        @$("#addHostModal input.install").focus()

    render: ->
      @new_hosts = @hosts.filter (h) -> h.is_new()
      @other_hosts = @hosts.filter (h) -> !h.is_new()
      @query ?= "" # set default val

      super()

      list = $(".new_host_list")
      _.eachR @, @new_hosts, (host) ->
        list.append @partial(exports.HostTableRow, { host: host }).$el

      list = $(".host_list")
      _.eachR @, @other_hosts, (host) ->
        list.append @partial(exports.HostTableRow, { host: host }).$el
