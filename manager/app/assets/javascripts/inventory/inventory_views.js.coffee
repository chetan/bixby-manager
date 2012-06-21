
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
      @hosts.eachR @, (host) ->
        list.append( @partial(exports.HostTableRow, { host: host }).$el )


  class exports.HostTableRow extends Stark.View
    template: "inventory/_host"
    tagName: "div"
    className: "host"

    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
      "div.body a.host":          [ "inv_view_host", (el) -> { host: @host } ]
    }

    bindings: [ "host" ]

    render: ->
      super
      @_he ||= @partial(exports.HostEditor, { host: @host })
      @_he.setButton( @$("span.edit button.edit") )

  class exports.Host extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host"

    bindings: [ "host" ]

    render: ->
      super

      if @_md?
        @_md.dispose()

      @_md = @partial exports.HostMetadata,
        { metadata: @host.get("metadata") },
        "div.host div.metadata"

      @_he ||= @partial(exports.HostEditor, { host: @host })
      @_he.setButton( @$("span.edit button.edit") )

  class exports.HostEditor extends Stark.View

    tagName: "div"
    className: "modal hide host_editor"
    template: "inventory/_host_editor"

    bindings: [ "host" ]

    setButton: (button) ->
      @button = button
      cb = _.bindR @, (ev) ->
        e = $(ev.target)
        if e.html() == "edit"
          @$el.modal("show")
          e.html("cancel")
        else
          @hide_editor()

      @button.on "click", cb

    events: {
      # save
      "click button.save": (e) ->
        e.preventDefault();
        @save_edits()

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault();
          @save_edits()
    }

    hide_editor: ->
      @button.html("edit")
      @$el.modal("hide")

    save_edits: ->
      @hide_editor()
      @host.set "alias", @$("input.alias").val(), {silent: true}
      @host.set "desc", @$("textarea.desc").val(), {silent: true}

      tags = ""
      _.each @$("ul.tags").tagit("tags"), (tag) ->
        tags += "," if tags.length > 0
        tags += tag.value
      @host.set "tags", tags, {silent: true}

      if @host.hasChanged()
        @host.save()

    after_render: ->
      @$("ul.tags").tagit();
      @$el.modal({ show: false })
      @$el.on "hidden", _.bindR(@, (ev) -> @hide_editor())
      @$el.on "shown", _.bindR(@, (ev) -> @$("input.alias").putCursorAtEnd())

  class exports.HostMetadata extends Stark.View
    template: "inventory/_metadata"
    bindings: [ "host" ]

    after_render: ->
      # show a popover for long values
      $("tbody tr").each (i, el) ->
        el = $(el)
        dc = el.attr("data-content")
        if dc.length > 40
          el.attr("data-content", "<pre>#{dc}</pre>")
          el.popover()
