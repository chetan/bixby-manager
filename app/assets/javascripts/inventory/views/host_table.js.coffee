namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    bindings: [ "hosts" ]

    render: ->
      @new_hosts = @hosts.filter (h) -> h.is_new()
      @other_hosts = @hosts.filter (h) -> !h.is_new()

      super()

      list = $(".new_host_list")
      _.eachR @, @new_hosts, (host) ->
        list.append( @partial(exports.HostTableNewRow, { host: host }).$el )

      list = $(".host_list")
      _.eachR @, @other_hosts, (host) ->
        list.append( @partial(exports.HostTableRow, { host: host }).$el )
