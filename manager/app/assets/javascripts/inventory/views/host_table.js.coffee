namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    render: ->
      super

      list = $(".host_list")
      @hosts.eachR @, (host) ->
        list.append( @partial(exports.HostTableRow, { host: host }).$el )
