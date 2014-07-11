
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostEditor extends Stark.View

    tagName: "div"
    className: "modal host_editor"
    template: "inventory/_host_editor"

    bindings: [ "host" ]

    events:
      # save
      "click button.save": (e) ->
        @save_edits()

      # delete
      "click button.delete": (e) ->
        @deleting = true # set a flag so we don't dispose yet
        @hide_editor()
        c = @create_partial Bixby.view.Confirm,
          message: "Are you sure you want to delete this host?",
          show_cb: null,
          hidden_cb: (confirmed) =>
            @deleting = false
            if confirmed
              @host.destroy()
              @hide_editor()
              @transition "inventory"
            else
              @$el.modal("show")
        c.render()

      # save (on enter)
      "keyup input.alias": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @save_edits()

    show: ->
      @$el.modal("show")

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
      @$el.on "shown.bs.modal", => @$("input.alias").putCursorAtEnd()
      @$el.on "hidden.bs.modal", =>
        @dispose() if !@deleting

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
