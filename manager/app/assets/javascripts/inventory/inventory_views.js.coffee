
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
      , @


  class exports.Host extends Stark.Partial
    template: "inventory/_host"
    tagName: "div"
    className: "host"

    events: {
      # edit
      "click span.edit a.edit": (e) ->
        e = @$(e.target)
        ed = @$(".editor")
        if e.html() == "edit"
          ed.show()
          e.html("cancel")
        else
          ed.hide()
          e.html("edit")

      # cancel
      "click div.editor a.cancel": (e) ->
        @$(".editor").hide()

      # save
      "click div.editor a.save": (e) ->
        @host.set "alias", @$(".editor input.alias").val()
        @host.set "desc", @$(".editor textarea.desc").val()
        @host.save()
        @$(".editor").hide()
    }

    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
    }
