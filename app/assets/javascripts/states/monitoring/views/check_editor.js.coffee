
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
        v = @
        v.check.destroy()
        v.hide_editor()
        v.parent.parent.redraw()

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
      command = @commands.get(@check.get("command_id"))

      args = {}

      _.each command.get("options"), (opt_hash, opt_key) ->
        args[opt_key] = @$("input##{opt_key}").val()

      @check.set {
          args: args
      }

      # set runhost if exists
      if @$("#runhost").length > 0

        if @check.get("agent_id") != parseInt(@$("#runhost").val())
          @check.set { agent_id: @$("#runhost").val() }
          # this is a workaround because the .set below clears the change event, see here:
          # http://stackoverflow.com/questions/5072435/backbone-js-not-registering-model-haschanged-event
          if @check.hasChanged()
            @check.save()
            @hide_editor()
            @parent.parent.redraw()
        if @check.hasChanged()
          @check.save()
          @hide_editor()
          @parent.parent.redraw()

      @hide_editor()

      if @check.hasChanged()
        @check.save()
        @parent.parent.redraw()

    after_render: ->
      @$el.modal({ show: false })
      @$el.on "hidden.bs.modal", _.bindR @, -> @redraw()

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
