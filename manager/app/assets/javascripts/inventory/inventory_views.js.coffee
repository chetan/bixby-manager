
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Layout extends Stark.View
    el: "#content"
    template: "inventory/layout"

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"

    render: ->
      super

      list = $(".host_list")
      @hosts.each (host) ->
        v = @create_partial(exports.Host, { host: host })
        list.append(v.$el)
        # v.attach_link_events()
      , @




  class exports.Host extends Stark.Partial
    template: "inventory/_host"
    tagName: "div"
    className: "host"
    events: {
      "click span.edit_body a.btn": (e) ->
        console.log @host.id
    }
    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) ->
        return { host: @host }
      ]
    }
