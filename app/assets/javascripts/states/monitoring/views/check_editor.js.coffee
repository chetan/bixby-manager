
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckEditor extends Stark.View

    tagName: "div"
    className: "modal check_editor"
    template: "monitoring/_check_editor"

    events:
      # save
      "click button.save": (e) ->
        @save_edits()

      # delete
      "click button.delete": (e) ->
        @hide_editor()
        @check.destroy()
        @hide_editor()
        @parent.parent.redraw()

      # save (on enter)
      "keypress input": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @save_edits()
          return false

    show: ->
      @$el.modal("show")
      @$("select, input, textarea").first().focus()

    hide_editor: ->
      @$el.modal("hide")
      @dispose()

    save_edits: ->
      args = {}
      _.each @check.command().get("options"), (opt_hash, opt_key) ->
        args[opt_key] = @$("input##{opt_key}").val()

      @check.set {
          args: args
      }

      # set runhost if exists
      if @$("#runhost").length > 0
        if @check.get("runhost_id") != @$("#runhost").val()
          @check.set { runhost_id: @$("#runhost").val() }

      @hide_editor()

      if @check.hasChanged()
        @check.save()
        @parent.parent.redraw()

    after_render: ->
      @$el.modal({ show: false })
