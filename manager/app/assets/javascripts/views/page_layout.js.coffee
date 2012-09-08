namespace "Bixby.view", (exports, top) ->

  class exports.PageLayout extends Stark.View

    redraw: false
    el: "#body"
    template: "page_layout"

    links: {
      "a.brand": [ "inventory" ]
      ".tab.inventory a": [ "inventory" ]
      ".tab.monitoring a": [ "monitoring" ]
    }

    app_events: {
      "state:activate": (state) ->
        if state.tab? and state.tab != @current_tab
          @current_tab = state.tab
          $("div.navbar li.tab").removeClass("active")
          $("div.navbar li.tab.#{@current_tab}").addClass("active")

      "search:set_query": (query) ->
        @set_query(query)

      "before:transition": ->
        @set_query("")

    }

    render: ->
      super
      @breadcrumb = @partial(exports.Breadcrumb)
      @$("#breadcrumb").append(@breadcrumb.$el)

    set_query: (q) ->
      $("div.navbar form.navbar-search input").val(q)

    get_query: ->
      return @query || ""

