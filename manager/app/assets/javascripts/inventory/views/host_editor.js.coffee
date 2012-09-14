namespace "Bixby.view.inventory", (exports, top) ->

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
        @log "save?"
        e.preventDefault();
        @save_edits()

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault();
          @save_edits()
    }

    hide_editor: (dispose) ->
      @button.html("edit")
      @$el.modal("hide")
      if dispose == true
        @dispose()
        return
      @redraw()

    save_edits: ->
      @host.set "alias", @$("input.alias").val(), {silent: true}
      @host.set "desc", @$("textarea.desc").val(), {silent: true}

      @host.set_tags _.pluck(@$("ul.tags").tagit("tags"), "value")

      if @host.hasChanged()
        @host.save()

      @hide_editor(true)

    after_render: ->
      @$("ul.tags").tagit();
      @$el.modal({ show: false })
      @$el.on "hidden", _.bindR(@, (ev) -> @hide_editor())
      @$el.on "shown", _.bindR(@, (ev) -> @$("input.alias").putCursorAtEnd())

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
