
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
      "keypress input#command_name, input#ps_command, input#ps_regex,
      input#alert_when_command_not_found, input#host, input#port, input#interfaces": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @save_edits()
          return false

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
        if @check.get("runhost_id") != @$("#runhost").val()
          @check.set { runhost_id: @$("#runhost").val() }

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
