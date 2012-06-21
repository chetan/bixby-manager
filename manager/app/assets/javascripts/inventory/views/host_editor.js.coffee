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
