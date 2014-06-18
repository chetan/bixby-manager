
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckEditor extends Stark.View

    tagName: "div"
    className: "modal host_editor"
    template: "monitoring/_check_editor"

    # bindings: [ "host" ]

    events:
      # save
      "click button.save": (e) ->
        @save_edits()

      # delete
      "click button.delete": (e) ->
        # @hide_editor()
        # v = @
        # c = new Bixby.view.Confirm({
        #   title: "Delete?",
        #   message: "Are you sure you want to delete this host?",
        #   show_cb: null,
        #   hidden_cb: (confirmed) ->
        #     if confirmed
        #       v.host.destroy()
        #       v.hide_editor()
        #       v.transition "inventory"
        #     else
        #       v.$el.modal("show")
        #   })
        # c.render()

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

      if @check.hasChanged()
        @check.save()

      # @host.set {
      #   alias: @$("input.alias").val()
      #   desc: @$("textarea.desc").val()
      #   tags: @$("input.tags").val()
      # }

      # if @host.hasChanged()
      #   @host.save()

      @hide_editor()

    after_render: ->
      # setup tag editor
      # tags = @$("input.tags")
      # tags.select2({
      #   tags: []
      #   tokenSeparators: [",", " "]
      # })
      # tags.on "change", (e) ->
      #   if e.added? and e.added.text.substr(0, 1) == "#"
      #     e.val.pop()
      #     e.val.push(e.added.text.substring(1))
      #     tags.val(e.val)
      #     setTimeoutR 0, -> # trigger async - otherwise it won't update UI
      #       tags.trigger("change")

      @$el.modal({ show: false })
      @$el.on "shown.bs.modal", _.bindR @, -> @$("input.alias").putCursorAtEnd()
      @$el.on "hidden.bs.modal", _.bindR @, -> @redraw()

    dispose: ->
      @$el.off "hidden"
      @$el.off "shown"
      super()
