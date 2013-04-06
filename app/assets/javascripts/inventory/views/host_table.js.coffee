namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    bindings: [ "hosts" ]

    events: {
      "focusin input.install": (e) ->
        $(e.target).mouseup (e) ->
          setTimeoutR 0, ->
            e.target.select()
          $(this).unbind()

        setTimeoutR 0, ->
          e.target.select()

      "click button.add_host":(e) ->
        e.preventDefault()
        $("#addHostModal").modal("show")

    }

    render: ->
      l = window.location
      @manager_uri = l.protocol + "//" + l.host
      @new_hosts = @hosts.filter (h) -> h.is_new()
      @other_hosts = @hosts.filter (h) -> !h.is_new()

      super()

      @$("#addHostModal").modal({show: false})
      @$("#addHostModal").on "shown", ->
        $("#addHostModal input.install").focus()

      list = $(".new_host_list")
      _.eachR @, @new_hosts, (host) ->
        list.append( @partial(exports.HostTableNewRow, { host: host }).$el )

      list = $(".host_list")
      _.eachR @, @other_hosts, (host) ->
        list.append( @partial(exports.HostTableRow, { host: host }).$el )
