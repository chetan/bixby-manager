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
        e.preventDefault()
        @save_edits()

      # delete
      "click button.delete": (e) ->
        e.preventDefault()
        @hide_editor()
        c = new Bixby.view.Confirm("Delete?", "Are you sure you want to delete this host?", null, @confirm_delete)

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @save_edits()
    }

    confirm_delete: (confirmed) ->
      if confirmed
        @delete_host()
      else
        @$el.modal("show")

    hide_editor: ->
      @$el.modal("hide")

    save_edits: ->
      @host.set "alias", @$("input.alias").val(), {silent: true}
      @host.set "desc", @$("textarea.desc").val(), {silent: true}

      @host.set_tags @$("input.tags").val()

      if @host.hasChanged()
        @host.save()

      @hide_editor()

    delete_host: ->
      @host.destroy()
      @hide_editor()

    after_render: ->
      # setup tag editor
      tags = @$("input.tags")
      tags.select2({
        tags: []
        tokenSeparators: [",", " "]
      })
      tags.on "change", (e) ->
        if e.added? and e.added.text.substr(0, 1) == "#"
          e.val.pop()
          e.val.push(e.added.text.substring(1))
          tags.val(e.val)
          setTimeoutR 0, -> # trigger async - otherwise it won't update UI
            tags.trigger("change")

      @$el.modal({ show: false })
      @$el.on "shown", _.bindR(@, (ev) -> @$("input.alias").putCursorAtEnd())
      @$el.on "hidden", _.bindR @, (ev) ->
        @button.html("edit")
        @redraw()

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
