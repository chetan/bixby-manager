
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostEditor extends Stark.View

    tagName: "div"
    className: "modal host_editor"
    template: "inventory/_host_editor"

    bindings: [ "host" ]

    setButton: (button) ->
      @button = button
      @button.on "click", _.bindR @, (ev) ->
        e = $(ev.target)
        if e.html() == "edit"
          @$el.modal("show")
          e.html("cancel")
        else
          @hide_editor()

    events: {
      # save
      "click button.save": (e) ->
        e.preventDefault()
        @save_edits()

      # delete
      "click button.delete": (e) ->
        e.preventDefault()
        @hide_editor()
        v = @
        c = new Bixby.view.Confirm({
          title: "Delete?",
          message: "Are you sure you want to delete this host?",
          show_cb: null,
          hidden_cb: (confirmed) ->
            if confirmed
              v.host.destroy()
              v.hide_editor()
              v.transition "inventory"
            else
              v.$el.modal("show")
          })
        c.render()

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @save_edits()
    }

    hide_editor: ->
      @$el.modal("hide")

    save_edits: ->
      @host.set {
        alias: @$("input.alias").val()
        desc: @$("textarea.desc").val()
        tags: @$("input.tags").val()
      }

      if @host.hasChanged()
        @host.save()

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
