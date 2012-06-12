
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
      "click span.edit button.edit": (e) ->
        e = @$(e.target)
        if e.html() == "edit"
          @$(".editor").show()
          @$("blockquote.desc").hide()
          e.html("cancel")
        else
          @hide_editor()

      # cancel
      "click div.editor button.cancel": (e) ->
        @hide_editor()

      # save
      "click div.editor button.save": (e) ->
        @save_edits()

      # save (on enter)
      "keyup div.editor input.alias": (e) ->
        if e.keyCode == 13
          @save_edits()
    }

    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
    }

    hide_editor: ->
      @$("span.edit button.edit").html("edit")
      @$(".editor").hide()
      @$("blockquote.desc").show()

    save_edits: ->
      @host.set "alias", @$(".editor input.alias").val()
      @host.set "desc", @$(".editor textarea.desc").val()
      @host.save()
      @hide_editor()

    after_render: ->
      @$('ul.tags').tagit();
