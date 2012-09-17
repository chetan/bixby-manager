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
        e.preventDefault();
        @save_edits()

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault();
          @save_edits()
    }

    hide_editor: ->
      @$el.modal("hide")

    save_edits: ->
      @host.set "alias", @$("input.alias").val(), {silent: true}
      @host.set "desc", @$("textarea.desc").val(), {silent: true}

      @host.set_tags _.pluck(@$("ul.tags").tagit("tags"), "value")

      if @host.hasChanged()
        @host.save()

      @hide_editor()

    after_render: ->
      tags = @$("ul.tags")
      tags.tagit({
        tagsChanged: (tag, action, el) ->
          if action == "added" and tag.substr(0, 1) == "#"
            tags.tagit("remove", tag)
            tags.tagit("add", tag.substr(1))
      })
      @$el.modal({ show: false })
      @$el.on "shown", _.bindR(@, (ev) -> @$("input.alias").putCursorAtEnd())
      @$el.on "hidden", _.bindR @, (ev) ->
        @button.html("edit")
        @redraw()

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
