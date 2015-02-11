namespace "Bixby.view", (exports, top) ->

  class exports.PageLayout extends Stark.View

    reuse: true
    el: "div.body"
    template: "main/page_layout"

    app_events:
      "state:activate": (state) ->
        # set the current tab name as a class on div#content
        if state.tab? and state.tab != @current_tab
          $("div#content").removeClass(@current_tab)
          @current_tab = state.tab
          $("div#content").addClass(@current_tab)

    dispose: ->
      $(document).off("swipedown")

    after_render: ->
      if Modernizr.touch # needed to avoid mouseclick fallback
        # refresh page when pulling down at top
        $(document).swipedown (e, info) =>
          if info.deltaY > 100
            @state.hard_refresh()
