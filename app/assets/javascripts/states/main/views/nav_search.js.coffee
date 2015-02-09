namespace "Bixby.view", (exports, top) ->

  class exports.NavSearch extends Stark.Partial

    reuse: true
    template: "main/nav_search"

    app_events:
      "search:set_query": (query) ->
        @set_query(query)

      "before:transition": ->
        @set_query("")

    events:
      "submit form": (e) ->
        e.preventDefault()
        @set_query($("form input").val())
        if @query and @query != ""
          @transition "inv_search", { query: @query }
        else
          @transition "inventory"

    set_query: (q) ->
      @query = q
      $("div.navbar form.navbar-search input").val(q)

    get_query: ->
      return @query || ""

