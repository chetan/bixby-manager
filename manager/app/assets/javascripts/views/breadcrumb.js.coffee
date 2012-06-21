namespace "Bixby.view", (exports, top) ->

  class exports.Breadcrumb extends Stark.View

    tagName: "ul"
    className: "breadcrumb"

    entries: null

    initialize: ->
      super
      @entries = []

    render: ->
      super
      if not @entries or @entries.length == 0
        $("#breadcrumb").addClass("hide")
        return

      $("#breadcrumb").removeClass("hide")
      @$el.empty()
      @$el.append("<li>foobar</li>")
